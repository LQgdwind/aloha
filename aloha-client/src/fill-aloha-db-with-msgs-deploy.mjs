<reference path="../rnode-grpc-gen/js/rnode-grpc-js.d.ts" />

import postgres from 'postgres'; 
import grpcLib from '@grpc/grpc-js';
import { rhoParToJson } from '@tgrospic/rnode-grpc-js';
import util from 'util';

// RNode with environment parameters
import { rnodeService } from './rnode-env.mjs';

// Load .env file
import { config } from 'dotenv';
config();

/**
  * @param {typeof process.env} env
  * @param {Object} arg
  * @param {typeof postgres} arg.postgres
  * @param {typeof grpcLib} arg.grpcLib 
  */

async function main(env, {postgres, grpcLib}) {
  const aloha_db_config = {
    host: 'localhost',
    port: 5442,
    database: 'aloha',
    username: 'aloha',
    password: process.env.POSTGRES_PASSWORD,
  };
  
  const { DB_CONTRACT_URI } = env;
  const sql = postgres(aloha_db_config);
  function fetchTables(){
    return `
      new return,
        lookup(\`rho:registry:lookup\`)
      in {
        new dbCh, tablesCh in {
          lookup!(\`${DB_CONTRACT_URI}\`, *dbCh) |
          for (db <- dbCh) {
            db!("tables", *tablesCh) |
            for (@tables <- tablesCh) {
              return!(("Tables", tables))
            }
          }
        }
      }
    `;
  } 
  function fetchTableKeys(tableName){
    return `
      new return,
        lookup(\`rho:registry:lookup\`)
      in {
        new dbCh, keysCh in {
          lookup!(\`${DB_CONTRACT_URI}\`, *dbCh) |
          for (db <- dbCh) {
            db!("keys", "${tableName}", *keysCh) |
            for (@keys <- keysCh) {
              return!(("keys", keys))
            }
          }
        }
      }
    `;
  }
  function fetchRecordInDB(table, ids){
    return `
      new return,
        lookup(\`rho:registry:lookup\`)
      in {
        new dbCh, selectCh in {
          lookup!(\`${DB_CONTRACT_URI}\`, *dbCh) |
          for (db <- dbCh) {
            db!("select", "${table}", [${ids}], *selectCh) |
            for (@keys <- selectCh) {
              return!(("select", keys))
            }
          }
        }
      }
    `;
  }
  function fetchTablesNames(result) {
    const par = result.postblockdataList[0];
    const rhoResult = rhoParToJson(par);
    return rhoResult[1];
  }
  function fetchKeys(result) {
    const par = result.postblockdataList[0];
    const rhoResult = rhoParToJson(par);
    return rhoResult[1][1];
  }
  function fetchDatafromAST(dataList){
    let messages = [];
    for (let msgData of dataList){
      let tupleBody = msgData.exprsList[0]?.eTupleBody;  
      if (tupleBody != undefined){
        for (let list of tupleBody.psList){
          if (list.exprsList[0]?.eMapBody != undefined){
            let dataList = list.exprsList[0]?.eMapBody.kvsList;
            for (let data of dataList){
              let mapBody = data.value.exprsList[0]?.eMapBody;        
              if (mapBody != undefined){
                let msg = {};
                msg["id"] = data.key.exprsList[0]?.gInt;
            
                for (let dictEl of mapBody.kvsList){    
                  if (dictEl.value){
                    let key = dictEl.key.exprsList[0]?.gString;
                    let valueSt = dictEl.value.exprsList[0]?.gString;
                    let valueInt = dictEl.value.exprsList[0]?.gInt;
                    let valueBool = dictEl.value.exprsList[0]?.gBool;
                    let value =  valueSt || valueInt || valueBool;
                    msg[key] = value;
                  }
                }
                messages.push(msg);
              }
            }
          }
        }
      }
    }
    return messages;
  }
  async function saveDataToDB(sql, tableName, data, keys, returnIds) {
    try {
      const insertedRecords = await sql`INSERT INTO ${sql(tableName)} ${sql(data, ...keys)} returning id`;
      console.log("# of records inserted:", data.length);
      if (returnIds){
        return insertedRecords;
      }
    } catch (error) {
      console.error("Postgres insert error: "+error);
      await sql.end();
    }
  }
  const { exploratorydp } = rnodeService(env, grpcLib);
  let insertedIds = [];
  let {result} = await exploratorydp({term: fetchTables()});
  const tablesNames = fetchTablesNames(result);
  
  for (let table of tablesNames){
    let returnIds = false;
    let {result} = await exploratorydp({term: fetchTableKeys(table)});
    const recordKeys = fetchKeys(result);

    let {result: resultRecords} = await exploratorydp({term: fetchRecordInDB(table, recordKeys)});
    const tableDataList = resultRecords.postblockdataList[0]?.exprsList[0]?.eTupleBody.psList;
    let tableData = fetchDatafromAST(tableDataList);
    if (table == "zerver_message"){
      returnIds = true;
    }

    if (table == "zerver_usermessage" && insertedIds.length){
      returnIds = false;
      for (let i = 0; i < tableData.length; i++){
        tableData[i].message_id = insertedIds[i].id;
      }
    } 
    let keys = Object.keys(tableData[0]).map(w => w.toString());
    keys.shift(); 
    insertedIds = await saveDataToDB(sql, table, tableData, keys, returnIds);
  }
  sql.end();
};
await main(process.env, {postgres, grpcLib});

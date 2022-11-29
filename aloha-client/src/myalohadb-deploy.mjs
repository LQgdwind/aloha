// Reference to TypeScript definitions for IntelliSense in VSCode
/// <reference path="../rnode-grpc-gen/js/rnode-grpc-js.d.ts" />
// @ts-check

import grpcLib from '@grpc/grpc-js';
import { promises as fs } from 'fs'
import util from 'util';

// RNode with environment parameters
import { rnodeService } from './rnode-env.mjs';

// Load .env file
import pkg from 'dotenv';
const { config } = pkg;
config();

/**
  * @param {typeof process.env} env
  * @param {object} arg
  * @param {typeof fs} arg.fs Node file system promises
  * @param {typeof grpcLib} arg.grpcLib Library '@grpc/grpc-js'
  */
async function main(env, {fs, grpcLib}) {
  const { IDDB_CONTRACT_URI } = env
  if (!IDDB_CONTRACT_URI) throw Error(`Environment parameter not set IDDB_CONTRACT_URI, check .env file.`);

  // fetch content of 'myalohadb.rho' file
  const rhoFile = new URL('rho/myalohadb.rho', import.meta.url);
  const rhoCodeTemplate = await fs.readFile(rhoFile, 'utf8');
  const rhoCode = rhoCodeTemplate.replace(/__ID_DB_URI__/, IDDB_CONTRACT_URI);

  // RNode connection
  const { senddp, fetchdpResult, proposeBlock } = rnodeService(env, grpcLib);

  // Send `myalohadb.rho` dp
  const {response: dpResponse, sig} = await senddp({term: rhoCode});
  console.log({ dpResponse });

  // Propose block
  const proposeResponse = await proposeBlock();
  console.log({ proposeResponse });

  // fetch registered URI (sent on `rho:rchain:dpId`)
  const dpResult = await fetchdpResult({sig});
  // console.log({dpResult: util.inspect(dpResult, {depth: 10, colors: true})});

  // Extract registry URI
  const uri = dpResult.payload?.blockinfoList[0]?.postblockdataList[0]?.exprsList[0]?.gUri;
  console.log({uri});
  console.log(`Copy URI to .env file DB_CONTRACT_URI variable.`);
};

main(process.env, {fs, grpcLib});

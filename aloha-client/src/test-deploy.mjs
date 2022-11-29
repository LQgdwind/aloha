// Reference to TypeScript definitions for IntelliSense in VSCode
/// <reference path="../rnode-grpc-gen/js/rnode-grpc-js.d.ts" />
// @ts-check

import grpcLib from '@grpc/grpc-js';
import test from 'tape';

// RNode with environment parameters
import { rnodeService } from '../src/rnode-env.mjs';

// Load .env file
import { config } from 'dotenv';
config();

import { rhoParToJson } from '@tgrospic/rnode-grpc-js';

test('dp test (required running RNode service defined in docker-compose.yml)', async t => {
  // RNode connection
  const { senddp, fetchdpResult, proposeBlock } = rnodeService(process.env, grpcLib);

  // Rholang term
  const term = `new return(\`rho:rchain:dpId\`) in { return!(42) }`;

  // 监听消息并且打印
  const {response: dpResponse, sig} = await senddp({term});
  console.log({ dpResponse });

  t.match(dpResponse.result, /^成功监听到一条消息! \n 消息ID是: [0-9a-fA-F]+$/, `Test send dp`);

  // 检查消息是否部署上链
  const proposeResponse = await proposeBlock();
  console.log({ proposeResponse });

  t.match(proposeResponse.result, /^确认成功部署一条消息! \n rchain区块实例 [0-9a-fA-F]+ 已经创建成功并且添加上链.$/, `Test block propose`);

  // dp result
  const dpResult = await fetchdpResult({sig});

  // Raw data (Par objects) returned from Rholang
  const par = dpResult.payload.blockinfoList[0].postblockdataList[0];

  const rhoResult = rhoParToJson(par);

  t.equal(rhoResult, 42, `Test dp result`);
});

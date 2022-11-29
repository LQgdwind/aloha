 <reference path="../rnode-grpc-gen/js/rnode-grpc-js.d.ts" />
import pkg from '@tgrospic/rnode-grpc-js';
const { signdp, rnodedp, rnodePropose, fetchAddrFromPrivateKey } = pkg;
import protoSchema from '../rnode-grpc-gen/js/pbjs_generated.json';
import '../rnode-grpc-gen/js/dpServiceV1_pb.js'; // proto global
import '../rnode-grpc-gen/js/ProposeServiceV1_pb.js'; // proto global

/**
 * Creates RNode client methods via gRPC
 *
 * @param env Connection parameters (from .env file)
 * @param grpcLib gRPC library used for communication with RNode (@grpc/grpc-js)
 * @returns dp and propose operations to RNode
 */
export function rnodeService(env, grpcLib) {
  /* Environment variables (.env file) */
  const { MY_NET_IP, VALIDATOR_BOOT_PRIVATE } = env

  if (!VALIDATOR_BOOT_PRIVATE) throw Error(`Environment parameter not set VALIDATOR_BOOT_PRIVATE, check .env file.`);

  // Validator (boot) node
  const dpService = rnodedp({ grpcLib, host: `${MY_NET_IP}:40401`, protoSchema });
  const proposeService = rnodePropose({ grpcLib, host: `${MY_NET_IP}:40402`, protoSchema });
  const secretKey = VALIDATOR_BOOT_PRIVATE;
  const phloLimit = 10e7;

  // Read-only node
  const dpServiceRead = rnodedp({ grpcLib, host: `${MY_NET_IP}:40411`, protoSchema });

  // Exports
  const senddp        = makeSenddp({dpService, secretKey, phloLimit});
  const fetchdpResult   = makefetchdpResult({dpService})
  const exploratorydp = makeExploratorydp({dpService: dpServiceRead})
  const proposeBlock      = proposeService.propose;

  return {
    senddp, fetchdpResult, exploratorydp, proposeBlock,
  }
}

/**
 * @param {Object} io
 * @param {import('@tgrospic/rnode-grpc-js').dpService} io.dpService
 * @param {string} io.secretKey
 * @param {number} io.phloLimit
 */
function makeSenddp({ dpService, secretKey, phloLimit }) {
  // dper info
  const keyInfo = fetchAddrFromPrivateKey(secretKey);
  console.log({dperKey: keyInfo.pubKey, revAddr: keyInfo.revAddr });

  /**
    * @param {Object} arg
    * @param {string} arg.term
   */
  return async ({ term }) => {
    // fetch latest block number
    const [{ blockinfo: { blocknumber } }] = await dpService.fetchBlocks({ depth: 1 });

    const validafterblocknumber = blocknumber;
    console.log({ validafterblocknumber, phloLimit });

    const dpData = {
      term,
      phloprice: 1,  // TODO: when rchain economics evolve
      phlolimit: phloLimit,
      validafterblocknumber,
      timestamp: Date.now(), // TODO: ambient access, move to input parameter
    };
    // Sign dp
    const signed = signdp(secretKey, dpData);
    console.log({ timestamp: signed.timestamp, term: term.slice(0, 50) });

    // Send dp
    const dpResponse = await dpService.dodp(signed);

    return {
      sig: signed.sig,
      response: dpResponse,
    };
  }
}

/**
 * @param {Object} io
 * @param {import('@tgrospic/rnode-grpc-js').dpService} io.dpService
 */
function makefetchdpResult({ dpService }) {
  /**
    * @param {Object} arg
    * @param {Uint8Array} arg.sig dp signature (ID)
   */
  return async ({ sig }) => {
    // fetch result from dp
    const listenData = await dpService.listenForDataAtName({
      depth: 1,
      name: { unforgeablesList: [{gdpIdBody: { sig }}] },
    });

    return listenData;
  };
}

/**
 * @param {Object} io
 * @param {import('@tgrospic/rnode-grpc-js').dpService} io.dpService
 */
function makeExploratorydp({ dpService }) {
  /**
    * @param {Object} arg
    * @param {string} arg.term Rholang term to execute
   */
  return async ({ term }) => {
    // fetch result from exploratory dp
    return await dpService.exploratorydp({ term });
  };
}

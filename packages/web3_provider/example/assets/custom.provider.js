(function () {
  function r(e, n, t) {
    function o(i, f) {
      if (!n[i]) {
        if (!e[i]) {
          var c = "function" == typeof require && require;
          if (!f && c) return c(i, !0);
          if (u) return u(i, !0);
          var a = new Error("Cannot find module '" + i + "'");
          throw ((a.code = "MODULE_NOT_FOUND"), a);
        }
        var p = (n[i] = { exports: {} });
        e[i][0].call(
          p.exports,
          function (r) {
            var n = e[i][1][r];
            return o(n || r);
          },
          p,
          p.exports,
          r,
          e,
          n,
          t
        );
      }
      return n[i].exports;
    }
    for (
      var u = "function" == typeof require && require, i = 0;
      i < t.length;
      i++
    )
      o(t[i]);
    return o;
  }
  return r;
})()(
  {
    1: [
      function (require, module, exports) {
        (function (Buffer) {
          (function () {
            "use strict";
            var __createBinding =
              (this && this.__createBinding) ||
              (Object.create
                ? function (o, m, k, k2) {
                    if (k2 === undefined) k2 = k;
                    Object.defineProperty(o, k2, {
                      enumerable: true,
                      get: function () {
                        return m[k];
                      },
                    });
                  }
                : function (o, m, k, k2) {
                    if (k2 === undefined) k2 = k;
                    o[k2] = m[k];
                  });
            var __setModuleDefault =
              (this && this.__setModuleDefault) ||
              (Object.create
                ? function (o, v) {
                    Object.defineProperty(o, "default", {
                      enumerable: true,
                      value: v,
                    });
                  }
                : function (o, v) {
                    o["default"] = v;
                  });
            var __importStar =
              (this && this.__importStar) ||
              function (mod) {
                if (mod && mod.__esModule) return mod;
                var result = {};
                if (mod != null)
                  for (var k in mod)
                    if (
                      k !== "default" &&
                      Object.prototype.hasOwnProperty.call(mod, k)
                    )
                      __createBinding(result, mod, k);
                __setModuleDefault(result, mod);
                return result;
              };
            Object.defineProperty(exports, "__esModule", { value: true });
            exports.getEncryptionPublicKey =
              exports.decryptSafely =
              exports.decrypt =
              exports.encryptSafely =
              exports.encrypt =
                void 0;
            const nacl = __importStar(require("tweetnacl"));
            const naclUtil = __importStar(require("tweetnacl-util"));
            const utils_1 = require("./utils");
            function encrypt({ publicKey, data, version }) {
              if (utils_1.isNullish(publicKey)) {
                throw new Error("Missing publicKey parameter");
              } else if (utils_1.isNullish(data)) {
                throw new Error("Missing data parameter");
              } else if (utils_1.isNullish(version)) {
                throw new Error("Missing version parameter");
              }
              switch (version) {
                case "x25519-xsalsa20-poly1305": {
                  if (typeof data !== "string") {
                    throw new Error("Message data must be given as a string");
                  }
                  const ephemeralKeyPair = nacl.box.keyPair();
                  let pubKeyUInt8Array;
                  try {
                    pubKeyUInt8Array = naclUtil.decodeBase64(publicKey);
                  } catch (err) {
                    throw new Error("Bad public key");
                  }
                  const msgParamsUInt8Array = naclUtil.decodeUTF8(data);
                  const nonce = nacl.randomBytes(nacl.box.nonceLength);
                  const encryptedMessage = nacl.box(
                    msgParamsUInt8Array,
                    nonce,
                    pubKeyUInt8Array,
                    ephemeralKeyPair.secretKey
                  );
                  const output = {
                    version: "x25519-xsalsa20-poly1305",
                    nonce: naclUtil.encodeBase64(nonce),
                    ephemPublicKey: naclUtil.encodeBase64(
                      ephemeralKeyPair.publicKey
                    ),
                    ciphertext: naclUtil.encodeBase64(encryptedMessage),
                  };
                  return output;
                }
                default:
                  throw new Error("Encryption type/version not supported");
              }
            }
            exports.encrypt = encrypt;
            function encryptSafely({ publicKey, data, version }) {
              if (utils_1.isNullish(publicKey)) {
                throw new Error("Missing publicKey parameter");
              } else if (utils_1.isNullish(data)) {
                throw new Error("Missing data parameter");
              } else if (utils_1.isNullish(version)) {
                throw new Error("Missing version parameter");
              }
              const DEFAULT_PADDING_LENGTH = 2 ** 11;
              const NACL_EXTRA_BYTES = 16;
              if (typeof data === "object" && "toJSON" in data) {
                throw new Error(
                  "Cannot encrypt with toJSON property.  Please remove toJSON property"
                );
              }
              const dataWithPadding = { data: data, padding: "" };
              const dataLength = Buffer.byteLength(
                JSON.stringify(dataWithPadding),
                "utf-8"
              );
              const modVal = dataLength % DEFAULT_PADDING_LENGTH;
              let padLength = 0;
              if (modVal > 0) {
                padLength = DEFAULT_PADDING_LENGTH - modVal - NACL_EXTRA_BYTES;
              }
              dataWithPadding.padding = "0".repeat(padLength);
              const paddedMessage = JSON.stringify(dataWithPadding);
              return encrypt({
                publicKey: publicKey,
                data: paddedMessage,
                version: version,
              });
            }
            exports.encryptSafely = encryptSafely;
            function decrypt({ encryptedData, privateKey }) {
              if (utils_1.isNullish(encryptedData)) {
                throw new Error("Missing encryptedData parameter");
              } else if (utils_1.isNullish(privateKey)) {
                throw new Error("Missing privateKey parameter");
              }
              switch (encryptedData.version) {
                case "x25519-xsalsa20-poly1305": {
                  const recieverPrivateKeyUint8Array =
                    nacl_decodeHex(privateKey);
                  const recieverEncryptionPrivateKey =
                    nacl.box.keyPair.fromSecretKey(
                      recieverPrivateKeyUint8Array
                    ).secretKey;
                  const nonce = naclUtil.decodeBase64(encryptedData.nonce);
                  const ciphertext = naclUtil.decodeBase64(
                    encryptedData.ciphertext
                  );
                  const ephemPublicKey = naclUtil.decodeBase64(
                    encryptedData.ephemPublicKey
                  );
                  const decryptedMessage = nacl.box.open(
                    ciphertext,
                    nonce,
                    ephemPublicKey,
                    recieverEncryptionPrivateKey
                  );
                  let output;
                  try {
                    output = naclUtil.encodeUTF8(decryptedMessage);
                  } catch (err) {
                    throw new Error("Decryption failed.");
                  }
                  if (output) {
                    return output;
                  }
                  throw new Error("Decryption failed.");
                }
                default:
                  throw new Error("Encryption type/version not supported.");
              }
            }
            exports.decrypt = decrypt;
            function decryptSafely({ encryptedData, privateKey }) {
              if (utils_1.isNullish(encryptedData)) {
                throw new Error("Missing encryptedData parameter");
              } else if (utils_1.isNullish(privateKey)) {
                throw new Error("Missing privateKey parameter");
              }
              const dataWithPadding = JSON.parse(
                decrypt({
                  encryptedData: encryptedData,
                  privateKey: privateKey,
                })
              );
              return dataWithPadding.data;
            }
            exports.decryptSafely = decryptSafely;
            function getEncryptionPublicKey(privateKey) {
              const privateKeyUint8Array = nacl_decodeHex(privateKey);
              const encryptionPublicKey =
                nacl.box.keyPair.fromSecretKey(privateKeyUint8Array).publicKey;
              return naclUtil.encodeBase64(encryptionPublicKey);
            }
            exports.getEncryptionPublicKey = getEncryptionPublicKey;
            function nacl_decodeHex(msgHex) {
              const msgBase64 = Buffer.from(msgHex, "hex").toString("base64");
              return naclUtil.decodeBase64(msgBase64);
            }
          }).call(this);
        }).call(this, require("buffer").Buffer);
      },
      { "./utils": 5, buffer: 25, tweetnacl: 156, "tweetnacl-util": 155 },
    ],
    2: [
      function (require, module, exports) {
        "use strict";
        var __createBinding =
          (this && this.__createBinding) ||
          (Object.create
            ? function (o, m, k, k2) {
                if (k2 === undefined) k2 = k;
                Object.defineProperty(o, k2, {
                  enumerable: true,
                  get: function () {
                    return m[k];
                  },
                });
              }
            : function (o, m, k, k2) {
                if (k2 === undefined) k2 = k;
                o[k2] = m[k];
              });
        var __exportStar =
          (this && this.__exportStar) ||
          function (m, exports) {
            for (var p in m)
              if (
                p !== "default" &&
                !Object.prototype.hasOwnProperty.call(exports, p)
              )
                __createBinding(exports, m, p);
          };
        Object.defineProperty(exports, "__esModule", { value: true });
        exports.normalize = exports.concatSig = void 0;
        __exportStar(require("./personal-sign"), exports);
        __exportStar(require("./sign-typed-data"), exports);
        __exportStar(require("./encryption"), exports);
        var utils_1 = require("./utils");
        Object.defineProperty(exports, "concatSig", {
          enumerable: true,
          get: function () {
            return utils_1.concatSig;
          },
        });
        Object.defineProperty(exports, "normalize", {
          enumerable: true,
          get: function () {
            return utils_1.normalize;
          },
        });
      },
      {
        "./encryption": 1,
        "./personal-sign": 3,
        "./sign-typed-data": 4,
        "./utils": 5,
      },
    ],
    3: [
      function (require, module, exports) {
        "use strict";
        Object.defineProperty(exports, "__esModule", { value: true });
        exports.extractPublicKey =
          exports.recoverPersonalSignature =
          exports.personalSign =
            void 0;
        const ethereumjs_util_1 = require("ethereumjs-util");
        const utils_1 = require("./utils");
        function personalSign({ privateKey, data }) {
          if (utils_1.isNullish(data)) {
            throw new Error("Missing data parameter");
          } else if (utils_1.isNullish(privateKey)) {
            throw new Error("Missing privateKey parameter");
          }
          const message = utils_1.legacyToBuffer(data);
          const msgHash = ethereumjs_util_1.hashPersonalMessage(message);
          const sig = ethereumjs_util_1.ecsign(msgHash, privateKey);
          const serialized = utils_1.concatSig(
            ethereumjs_util_1.toBuffer(sig.v),
            sig.r,
            sig.s
          );
          return serialized;
        }
        exports.personalSign = personalSign;
        function recoverPersonalSignature({ data, signature }) {
          if (utils_1.isNullish(data)) {
            throw new Error("Missing data parameter");
          } else if (utils_1.isNullish(signature)) {
            throw new Error("Missing signature parameter");
          }
          const publicKey = getPublicKeyFor(data, signature);
          const sender = ethereumjs_util_1.publicToAddress(publicKey);
          const senderHex = ethereumjs_util_1.bufferToHex(sender);
          return senderHex;
        }
        exports.recoverPersonalSignature = recoverPersonalSignature;
        function extractPublicKey({ data, signature }) {
          if (utils_1.isNullish(data)) {
            throw new Error("Missing data parameter");
          } else if (utils_1.isNullish(signature)) {
            throw new Error("Missing signature parameter");
          }
          const publicKey = getPublicKeyFor(data, signature);
          return `0x${publicKey.toString("hex")}`;
        }
        exports.extractPublicKey = extractPublicKey;
        function getPublicKeyFor(message, signature) {
          const messageHash = ethereumjs_util_1.hashPersonalMessage(
            utils_1.legacyToBuffer(message)
          );
          return utils_1.recoverPublicKey(messageHash, signature);
        }
      },
      { "./utils": 5, "ethereumjs-util": 11 },
    ],
    4: [
      function (require, module, exports) {
        (function (Buffer) {
          (function () {
            "use strict";
            Object.defineProperty(exports, "__esModule", { value: true });
            exports.recoverTypedSignature =
              exports.signTypedData =
              exports.typedSignatureHash =
              exports.TypedDataUtils =
              exports.TYPED_MESSAGE_SCHEMA =
              exports.SignTypedDataVersion =
                void 0;
            const ethereumjs_util_1 = require("ethereumjs-util");
            const ethereumjs_abi_1 = require("ethereumjs-abi");
            const utils_1 = require("./utils");
            var SignTypedDataVersion;
            (function (SignTypedDataVersion) {
              SignTypedDataVersion["V1"] = "V1";
              SignTypedDataVersion["V3"] = "V3";
              SignTypedDataVersion["V4"] = "V4";
            })(
              (SignTypedDataVersion =
                exports.SignTypedDataVersion ||
                (exports.SignTypedDataVersion = {}))
            );
            exports.TYPED_MESSAGE_SCHEMA = {
              type: "object",
              properties: {
                types: {
                  type: "object",
                  additionalProperties: {
                    type: "array",
                    items: {
                      type: "object",
                      properties: {
                        name: { type: "string" },
                        type: { type: "string" },
                      },
                      required: ["name", "type"],
                    },
                  },
                },
                primaryType: { type: "string" },
                domain: { type: "object" },
                message: { type: "object" },
              },
              required: ["types", "primaryType", "domain", "message"],
            };
            function validateVersion(version, allowedVersions) {
              if (!Object.keys(SignTypedDataVersion).includes(version)) {
                throw new Error(`Invalid version: '${version}'`);
              } else if (
                allowedVersions &&
                !allowedVersions.includes(version)
              ) {
                throw new Error(
                  `SignTypedDataVersion not allowed: '${version}'. Allowed versions are: ${allowedVersions.join(
                    ", "
                  )}`
                );
              }
            }
            function encodeField(types, name, type, value, version) {
              validateVersion(version, [
                SignTypedDataVersion.V3,
                SignTypedDataVersion.V4,
              ]);
              if (types[type] !== undefined) {
                return [
                  "bytes32",
                  version === SignTypedDataVersion.V4 && value == null
                    ? "0x0000000000000000000000000000000000000000000000000000000000000000"
                    : ethereumjs_util_1.keccak(
                        encodeData(type, value, types, version)
                      ),
                ];
              }
              if (value === undefined) {
                throw new Error(
                  `missing value for field ${name} of type ${type}`
                );
              }
              if (type === "bytes") {
                return ["bytes32", ethereumjs_util_1.keccak(value)];
              }
              if (type === "string") {
                if (typeof value === "string") {
                  value = Buffer.from(value, "utf8");
                }
                return ["bytes32", ethereumjs_util_1.keccak(value)];
              }
              if (type.lastIndexOf("]") === type.length - 1) {
                if (version === SignTypedDataVersion.V3) {
                  throw new Error(
                    "Arrays are unimplemented in encodeData; use V4 extension"
                  );
                }
                const parsedType = type.slice(0, type.lastIndexOf("["));
                const typeValuePairs = value.map((item) =>
                  encodeField(types, name, parsedType, item, version)
                );
                return [
                  "bytes32",
                  ethereumjs_util_1.keccak(
                    ethereumjs_abi_1.rawEncode(
                      typeValuePairs.map(([t]) => t),
                      typeValuePairs.map(([, v]) => v)
                    )
                  ),
                ];
              }
              return [type, value];
            }
            function encodeData(primaryType, data, types, version) {
              validateVersion(version, [
                SignTypedDataVersion.V3,
                SignTypedDataVersion.V4,
              ]);
              const encodedTypes = ["bytes32"];
              const encodedValues = [hashType(primaryType, types)];
              for (const field of types[primaryType]) {
                if (
                  version === SignTypedDataVersion.V3 &&
                  data[field.name] === undefined
                ) {
                  continue;
                }
                const [type, value] = encodeField(
                  types,
                  field.name,
                  field.type,
                  data[field.name],
                  version
                );
                encodedTypes.push(type);
                encodedValues.push(value);
              }
              return ethereumjs_abi_1.rawEncode(encodedTypes, encodedValues);
            }
            function encodeType(primaryType, types) {
              let result = "";
              const unsortedDeps = findTypeDependencies(primaryType, types);
              unsortedDeps.delete(primaryType);
              const deps = [primaryType, ...Array.from(unsortedDeps).sort()];
              for (const type of deps) {
                const children = types[type];
                if (!children) {
                  throw new Error(`No type definition specified: ${type}`);
                }
                result += `${type}(${types[type]
                  .map(({ name, type: t }) => `${t} ${name}`)
                  .join(",")})`;
              }
              return result;
            }
            function findTypeDependencies(
              primaryType,
              types,
              results = new Set()
            ) {
              [primaryType] = primaryType.match(/^\w*/u);
              if (
                results.has(primaryType) ||
                types[primaryType] === undefined
              ) {
                return results;
              }
              results.add(primaryType);
              for (const field of types[primaryType]) {
                findTypeDependencies(field.type, types, results);
              }
              return results;
            }
            function hashStruct(primaryType, data, types, version) {
              validateVersion(version, [
                SignTypedDataVersion.V3,
                SignTypedDataVersion.V4,
              ]);
              return ethereumjs_util_1.keccak(
                encodeData(primaryType, data, types, version)
              );
            }
            function hashType(primaryType, types) {
              return ethereumjs_util_1.keccak(encodeType(primaryType, types));
            }
            function sanitizeData(data) {
              const sanitizedData = {};
              for (const key in exports.TYPED_MESSAGE_SCHEMA.properties) {
                if (data[key]) {
                  sanitizedData[key] = data[key];
                }
              }
              if ("types" in sanitizedData) {
                sanitizedData.types = Object.assign(
                  { EIP712Domain: [] },
                  sanitizedData.types
                );
              }
              return sanitizedData;
            }
            function eip712Hash(typedData, version) {
              validateVersion(version, [
                SignTypedDataVersion.V3,
                SignTypedDataVersion.V4,
              ]);
              const sanitizedData = sanitizeData(typedData);
              const parts = [Buffer.from("1901", "hex")];
              parts.push(
                hashStruct(
                  "EIP712Domain",
                  sanitizedData.domain,
                  sanitizedData.types,
                  version
                )
              );
              if (sanitizedData.primaryType !== "EIP712Domain") {
                parts.push(
                  hashStruct(
                    sanitizedData.primaryType,
                    sanitizedData.message,
                    sanitizedData.types,
                    version
                  )
                );
              }
              return ethereumjs_util_1.keccak(Buffer.concat(parts));
            }
            exports.TypedDataUtils = {
              encodeData: encodeData,
              encodeType: encodeType,
              findTypeDependencies: findTypeDependencies,
              hashStruct: hashStruct,
              hashType: hashType,
              sanitizeData: sanitizeData,
              eip712Hash: eip712Hash,
            };
            function typedSignatureHash(typedData) {
              const hashBuffer = _typedSignatureHash(typedData);
              return ethereumjs_util_1.bufferToHex(hashBuffer);
            }
            exports.typedSignatureHash = typedSignatureHash;
            function _typedSignatureHash(typedData) {
              const error = new Error("Expect argument to be non-empty array");
              if (
                typeof typedData !== "object" ||
                !("length" in typedData) ||
                !typedData.length
              ) {
                throw error;
              }
              const data = typedData.map(function (e) {
                if (e.type !== "bytes") {
                  return e.value;
                }
                return utils_1.legacyToBuffer(e.value);
              });
              const types = typedData.map(function (e) {
                return e.type;
              });
              const schema = typedData.map(function (e) {
                if (!e.name) {
                  throw error;
                }
                return `${e.type} ${e.name}`;
              });
              return ethereumjs_abi_1.soliditySHA3(
                ["bytes32", "bytes32"],
                [
                  ethereumjs_abi_1.soliditySHA3(
                    new Array(typedData.length).fill("string"),
                    schema
                  ),
                  ethereumjs_abi_1.soliditySHA3(types, data),
                ]
              );
            }
            function signTypedData({ privateKey, data, version }) {
              validateVersion(version);
              if (utils_1.isNullish(data)) {
                throw new Error("Missing data parameter");
              } else if (utils_1.isNullish(privateKey)) {
                throw new Error("Missing private key parameter");
              }
              const messageHash =
                version === SignTypedDataVersion.V1
                  ? _typedSignatureHash(data)
                  : exports.TypedDataUtils.eip712Hash(data, version);
              const sig = ethereumjs_util_1.ecsign(messageHash, privateKey);
              return utils_1.concatSig(
                ethereumjs_util_1.toBuffer(sig.v),
                sig.r,
                sig.s
              );
            }
            exports.signTypedData = signTypedData;
            function recoverTypedSignature({ data, signature, version }) {
              validateVersion(version);
              if (utils_1.isNullish(data)) {
                throw new Error("Missing data parameter");
              } else if (utils_1.isNullish(signature)) {
                throw new Error("Missing signature parameter");
              }
              const messageHash =
                version === SignTypedDataVersion.V1
                  ? _typedSignatureHash(data)
                  : exports.TypedDataUtils.eip712Hash(data, version);
              const publicKey = utils_1.recoverPublicKey(
                messageHash,
                signature
              );
              const sender = ethereumjs_util_1.publicToAddress(publicKey);
              return ethereumjs_util_1.bufferToHex(sender);
            }
            exports.recoverTypedSignature = recoverTypedSignature;
          }).call(this);
        }).call(this, require("buffer").Buffer);
      },
      { "./utils": 5, buffer: 25, "ethereumjs-abi": 49, "ethereumjs-util": 11 },
    ],
    5: [
      function (require, module, exports) {
        (function (Buffer) {
          (function () {
            "use strict";
            Object.defineProperty(exports, "__esModule", { value: true });
            exports.normalize =
              exports.recoverPublicKey =
              exports.concatSig =
              exports.legacyToBuffer =
              exports.isNullish =
              exports.padWithZeroes =
                void 0;
            const ethereumjs_util_1 = require("ethereumjs-util");
            const ethjs_util_1 = require("ethjs-util");
            function padWithZeroes(hexString, targetLength) {
              if (hexString !== "" && !/^[a-f0-9]+$/iu.test(hexString)) {
                throw new Error(
                  `Expected an unprefixed hex string. Received: ${hexString}`
                );
              }
              if (targetLength < 0) {
                throw new Error(
                  `Expected a non-negative integer target length. Received: ${targetLength}`
                );
              }
              return String.prototype.padStart.call(
                hexString,
                targetLength,
                "0"
              );
            }
            exports.padWithZeroes = padWithZeroes;
            function isNullish(value) {
              return value === null || value === undefined;
            }
            exports.isNullish = isNullish;
            function legacyToBuffer(value) {
              return typeof value === "string" &&
                !ethjs_util_1.isHexString(value)
                ? Buffer.from(value)
                : ethereumjs_util_1.toBuffer(value);
            }
            exports.legacyToBuffer = legacyToBuffer;
            function concatSig(v, r, s) {
              const rSig = ethereumjs_util_1.fromSigned(r);
              const sSig = ethereumjs_util_1.fromSigned(s);
              const vSig = ethereumjs_util_1.bufferToInt(v);
              const rStr = padWithZeroes(
                ethereumjs_util_1.toUnsigned(rSig).toString("hex"),
                64
              );
              const sStr = padWithZeroes(
                ethereumjs_util_1.toUnsigned(sSig).toString("hex"),
                64
              );
              const vStr = ethjs_util_1.stripHexPrefix(
                ethjs_util_1.intToHex(vSig)
              );
              return ethereumjs_util_1.addHexPrefix(rStr.concat(sStr, vStr));
            }
            exports.concatSig = concatSig;
            function recoverPublicKey(messageHash, signature) {
              const sigParams = ethereumjs_util_1.fromRpcSig(signature);
              return ethereumjs_util_1.ecrecover(
                messageHash,
                sigParams.v,
                sigParams.r,
                sigParams.s
              );
            }
            exports.recoverPublicKey = recoverPublicKey;
            function normalize(input) {
              if (!input) {
                return undefined;
              }
              if (typeof input === "number") {
                const buffer = ethereumjs_util_1.toBuffer(input);
                input = ethereumjs_util_1.bufferToHex(buffer);
              }
              if (typeof input !== "string") {
                let msg =
                  "eth-sig-util.normalize() requires hex string or integer input.";
                msg += ` received ${typeof input}: ${input}`;
                throw new Error(msg);
              }
              return ethereumjs_util_1.addHexPrefix(input.toLowerCase());
            }
            exports.normalize = normalize;
          }).call(this);
        }).call(this, require("buffer").Buffer);
      },
      { buffer: 25, "ethereumjs-util": 11, "ethjs-util": 62 },
    ],
    6: [
      function (require, module, exports) {
        (function (module, exports) {
          "use strict";
          function assert(val, msg) {
            if (!val) throw new Error(msg || "Assertion failed");
          }
          function inherits(ctor, superCtor) {
            ctor.super_ = superCtor;
            var TempCtor = function () {};
            TempCtor.prototype = superCtor.prototype;
            ctor.prototype = new TempCtor();
            ctor.prototype.constructor = ctor;
          }
          function BN(number, base, endian) {
            if (BN.isBN(number)) {
              return number;
            }
            this.negative = 0;
            this.words = null;
            this.length = 0;
            this.red = null;
            if (number !== null) {
              if (base === "le" || base === "be") {
                endian = base;
                base = 10;
              }
              this._init(number || 0, base || 10, endian || "be");
            }
          }
          if (typeof module === "object") {
            module.exports = BN;
          } else {
            exports.BN = BN;
          }
          BN.BN = BN;
          BN.wordSize = 26;
          var Buffer;
          try {
            if (
              typeof window !== "undefined" &&
              typeof window.Buffer !== "undefined"
            ) {
              Buffer = window.Buffer;
            } else {
              Buffer = require("buffer").Buffer;
            }
          } catch (e) {}
          BN.isBN = function isBN(num) {
            if (num instanceof BN) {
              return true;
            }
            return (
              num !== null &&
              typeof num === "object" &&
              num.constructor.wordSize === BN.wordSize &&
              Array.isArray(num.words)
            );
          };
          BN.max = function max(left, right) {
            if (left.cmp(right) > 0) return left;
            return right;
          };
          BN.min = function min(left, right) {
            if (left.cmp(right) < 0) return left;
            return right;
          };
          BN.prototype._init = function init(number, base, endian) {
            if (typeof number === "number") {
              return this._initNumber(number, base, endian);
            }
            if (typeof number === "object") {
              return this._initArray(number, base, endian);
            }
            if (base === "hex") {
              base = 16;
            }
            assert(base === (base | 0) && base >= 2 && base <= 36);
            number = number.toString().replace(/\s+/g, "");
            var start = 0;
            if (number[0] === "-") {
              start++;
              this.negative = 1;
            }
            if (start < number.length) {
              if (base === 16) {
                this._parseHex(number, start, endian);
              } else {
                this._parseBase(number, base, start);
                if (endian === "le") {
                  this._initArray(this.toArray(), base, endian);
                }
              }
            }
          };
          BN.prototype._initNumber = function _initNumber(
            number,
            base,
            endian
          ) {
            if (number < 0) {
              this.negative = 1;
              number = -number;
            }
            if (number < 67108864) {
              this.words = [number & 67108863];
              this.length = 1;
            } else if (number < 4503599627370496) {
              this.words = [number & 67108863, (number / 67108864) & 67108863];
              this.length = 2;
            } else {
              assert(number < 9007199254740992);
              this.words = [
                number & 67108863,
                (number / 67108864) & 67108863,
                1,
              ];
              this.length = 3;
            }
            if (endian !== "le") return;
            this._initArray(this.toArray(), base, endian);
          };
          BN.prototype._initArray = function _initArray(number, base, endian) {
            assert(typeof number.length === "number");
            if (number.length <= 0) {
              this.words = [0];
              this.length = 1;
              return this;
            }
            this.length = Math.ceil(number.length / 3);
            this.words = new Array(this.length);
            for (var i = 0; i < this.length; i++) {
              this.words[i] = 0;
            }
            var j, w;
            var off = 0;
            if (endian === "be") {
              for (i = number.length - 1, j = 0; i >= 0; i -= 3) {
                w = number[i] | (number[i - 1] << 8) | (number[i - 2] << 16);
                this.words[j] |= (w << off) & 67108863;
                this.words[j + 1] = (w >>> (26 - off)) & 67108863;
                off += 24;
                if (off >= 26) {
                  off -= 26;
                  j++;
                }
              }
            } else if (endian === "le") {
              for (i = 0, j = 0; i < number.length; i += 3) {
                w = number[i] | (number[i + 1] << 8) | (number[i + 2] << 16);
                this.words[j] |= (w << off) & 67108863;
                this.words[j + 1] = (w >>> (26 - off)) & 67108863;
                off += 24;
                if (off >= 26) {
                  off -= 26;
                  j++;
                }
              }
            }
            return this.strip();
          };
          function parseHex4Bits(string, index) {
            var c = string.charCodeAt(index);
            if (c >= 65 && c <= 70) {
              return c - 55;
            } else if (c >= 97 && c <= 102) {
              return c - 87;
            } else {
              return (c - 48) & 15;
            }
          }
          function parseHexByte(string, lowerBound, index) {
            var r = parseHex4Bits(string, index);
            if (index - 1 >= lowerBound) {
              r |= parseHex4Bits(string, index - 1) << 4;
            }
            return r;
          }
          BN.prototype._parseHex = function _parseHex(number, start, endian) {
            this.length = Math.ceil((number.length - start) / 6);
            this.words = new Array(this.length);
            for (var i = 0; i < this.length; i++) {
              this.words[i] = 0;
            }
            var off = 0;
            var j = 0;
            var w;
            if (endian === "be") {
              for (i = number.length - 1; i >= start; i -= 2) {
                w = parseHexByte(number, start, i) << off;
                this.words[j] |= w & 67108863;
                if (off >= 18) {
                  off -= 18;
                  j += 1;
                  this.words[j] |= w >>> 26;
                } else {
                  off += 8;
                }
              }
            } else {
              var parseLength = number.length - start;
              for (
                i = parseLength % 2 === 0 ? start + 1 : start;
                i < number.length;
                i += 2
              ) {
                w = parseHexByte(number, start, i) << off;
                this.words[j] |= w & 67108863;
                if (off >= 18) {
                  off -= 18;
                  j += 1;
                  this.words[j] |= w >>> 26;
                } else {
                  off += 8;
                }
              }
            }
            this.strip();
          };
          function parseBase(str, start, end, mul) {
            var r = 0;
            var len = Math.min(str.length, end);
            for (var i = start; i < len; i++) {
              var c = str.charCodeAt(i) - 48;
              r *= mul;
              if (c >= 49) {
                r += c - 49 + 10;
              } else if (c >= 17) {
                r += c - 17 + 10;
              } else {
                r += c;
              }
            }
            return r;
          }
          BN.prototype._parseBase = function _parseBase(number, base, start) {
            this.words = [0];
            this.length = 1;
            for (
              var limbLen = 0, limbPow = 1;
              limbPow <= 67108863;
              limbPow *= base
            ) {
              limbLen++;
            }
            limbLen--;
            limbPow = (limbPow / base) | 0;
            var total = number.length - start;
            var mod = total % limbLen;
            var end = Math.min(total, total - mod) + start;
            var word = 0;
            for (var i = start; i < end; i += limbLen) {
              word = parseBase(number, i, i + limbLen, base);
              this.imuln(limbPow);
              if (this.words[0] + word < 67108864) {
                this.words[0] += word;
              } else {
                this._iaddn(word);
              }
            }
            if (mod !== 0) {
              var pow = 1;
              word = parseBase(number, i, number.length, base);
              for (i = 0; i < mod; i++) {
                pow *= base;
              }
              this.imuln(pow);
              if (this.words[0] + word < 67108864) {
                this.words[0] += word;
              } else {
                this._iaddn(word);
              }
            }
            this.strip();
          };
          BN.prototype.copy = function copy(dest) {
            dest.words = new Array(this.length);
            for (var i = 0; i < this.length; i++) {
              dest.words[i] = this.words[i];
            }
            dest.length = this.length;
            dest.negative = this.negative;
            dest.red = this.red;
          };
          BN.prototype.clone = function clone() {
            var r = new BN(null);
            this.copy(r);
            return r;
          };
          BN.prototype._expand = function _expand(size) {
            while (this.length < size) {
              this.words[this.length++] = 0;
            }
            return this;
          };
          BN.prototype.strip = function strip() {
            while (this.length > 1 && this.words[this.length - 1] === 0) {
              this.length--;
            }
            return this._normSign();
          };
          BN.prototype._normSign = function _normSign() {
            if (this.length === 1 && this.words[0] === 0) {
              this.negative = 0;
            }
            return this;
          };
          BN.prototype.inspect = function inspect() {
            return (this.red ? "<BN-R: " : "<BN: ") + this.toString(16) + ">";
          };
          var zeros = [
            "",
            "0",
            "00",
            "000",
            "0000",
            "00000",
            "000000",
            "0000000",
            "00000000",
            "000000000",
            "0000000000",
            "00000000000",
            "000000000000",
            "0000000000000",
            "00000000000000",
            "000000000000000",
            "0000000000000000",
            "00000000000000000",
            "000000000000000000",
            "0000000000000000000",
            "00000000000000000000",
            "000000000000000000000",
            "0000000000000000000000",
            "00000000000000000000000",
            "000000000000000000000000",
            "0000000000000000000000000",
          ];
          var groupSizes = [
            0, 0, 25, 16, 12, 11, 10, 9, 8, 8, 7, 7, 7, 7, 6, 6, 6, 6, 6, 6, 6,
            5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
          ];
          var groupBases = [
            0, 0, 33554432, 43046721, 16777216, 48828125, 60466176, 40353607,
            16777216, 43046721, 1e7, 19487171, 35831808, 62748517, 7529536,
            11390625, 16777216, 24137569, 34012224, 47045881, 64e6, 4084101,
            5153632, 6436343, 7962624, 9765625, 11881376, 14348907, 17210368,
            20511149, 243e5, 28629151, 33554432, 39135393, 45435424, 52521875,
            60466176,
          ];
          BN.prototype.toString = function toString(base, padding) {
            base = base || 10;
            padding = padding | 0 || 1;
            var out;
            if (base === 16 || base === "hex") {
              out = "";
              var off = 0;
              var carry = 0;
              for (var i = 0; i < this.length; i++) {
                var w = this.words[i];
                var word = (((w << off) | carry) & 16777215).toString(16);
                carry = (w >>> (24 - off)) & 16777215;
                if (carry !== 0 || i !== this.length - 1) {
                  out = zeros[6 - word.length] + word + out;
                } else {
                  out = word + out;
                }
                off += 2;
                if (off >= 26) {
                  off -= 26;
                  i--;
                }
              }
              if (carry !== 0) {
                out = carry.toString(16) + out;
              }
              while (out.length % padding !== 0) {
                out = "0" + out;
              }
              if (this.negative !== 0) {
                out = "-" + out;
              }
              return out;
            }
            if (base === (base | 0) && base >= 2 && base <= 36) {
              var groupSize = groupSizes[base];
              var groupBase = groupBases[base];
              out = "";
              var c = this.clone();
              c.negative = 0;
              while (!c.isZero()) {
                var r = c.modn(groupBase).toString(base);
                c = c.idivn(groupBase);
                if (!c.isZero()) {
                  out = zeros[groupSize - r.length] + r + out;
                } else {
                  out = r + out;
                }
              }
              if (this.isZero()) {
                out = "0" + out;
              }
              while (out.length % padding !== 0) {
                out = "0" + out;
              }
              if (this.negative !== 0) {
                out = "-" + out;
              }
              return out;
            }
            assert(false, "Base should be between 2 and 36");
          };
          BN.prototype.toNumber = function toNumber() {
            var ret = this.words[0];
            if (this.length === 2) {
              ret += this.words[1] * 67108864;
            } else if (this.length === 3 && this.words[2] === 1) {
              ret += 4503599627370496 + this.words[1] * 67108864;
            } else if (this.length > 2) {
              assert(false, "Number can only safely store up to 53 bits");
            }
            return this.negative !== 0 ? -ret : ret;
          };
          BN.prototype.toJSON = function toJSON() {
            return this.toString(16);
          };
          BN.prototype.toBuffer = function toBuffer(endian, length) {
            assert(typeof Buffer !== "undefined");
            return this.toArrayLike(Buffer, endian, length);
          };
          BN.prototype.toArray = function toArray(endian, length) {
            return this.toArrayLike(Array, endian, length);
          };
          BN.prototype.toArrayLike = function toArrayLike(
            ArrayType,
            endian,
            length
          ) {
            var byteLength = this.byteLength();
            var reqLength = length || Math.max(1, byteLength);
            assert(
              byteLength <= reqLength,
              "byte array longer than desired length"
            );
            assert(reqLength > 0, "Requested array length <= 0");
            this.strip();
            var littleEndian = endian === "le";
            var res = new ArrayType(reqLength);
            var b, i;
            var q = this.clone();
            if (!littleEndian) {
              for (i = 0; i < reqLength - byteLength; i++) {
                res[i] = 0;
              }
              for (i = 0; !q.isZero(); i++) {
                b = q.andln(255);
                q.iushrn(8);
                res[reqLength - i - 1] = b;
              }
            } else {
              for (i = 0; !q.isZero(); i++) {
                b = q.andln(255);
                q.iushrn(8);
                res[i] = b;
              }
              for (; i < reqLength; i++) {
                res[i] = 0;
              }
            }
            return res;
          };
          if (Math.clz32) {
            BN.prototype._countBits = function _countBits(w) {
              return 32 - Math.clz32(w);
            };
          } else {
            BN.prototype._countBits = function _countBits(w) {
              var t = w;
              var r = 0;
              if (t >= 4096) {
                r += 13;
                t >>>= 13;
              }
              if (t >= 64) {
                r += 7;
                t >>>= 7;
              }
              if (t >= 8) {
                r += 4;
                t >>>= 4;
              }
              if (t >= 2) {
                r += 2;
                t >>>= 2;
              }
              return r + t;
            };
          }
          BN.prototype._zeroBits = function _zeroBits(w) {
            if (w === 0) return 26;
            var t = w;
            var r = 0;
            if ((t & 8191) === 0) {
              r += 13;
              t >>>= 13;
            }
            if ((t & 127) === 0) {
              r += 7;
              t >>>= 7;
            }
            if ((t & 15) === 0) {
              r += 4;
              t >>>= 4;
            }
            if ((t & 3) === 0) {
              r += 2;
              t >>>= 2;
            }
            if ((t & 1) === 0) {
              r++;
            }
            return r;
          };
          BN.prototype.bitLength = function bitLength() {
            var w = this.words[this.length - 1];
            var hi = this._countBits(w);
            return (this.length - 1) * 26 + hi;
          };
          function toBitArray(num) {
            var w = new Array(num.bitLength());
            for (var bit = 0; bit < w.length; bit++) {
              var off = (bit / 26) | 0;
              var wbit = bit % 26;
              w[bit] = (num.words[off] & (1 << wbit)) >>> wbit;
            }
            return w;
          }
          BN.prototype.zeroBits = function zeroBits() {
            if (this.isZero()) return 0;
            var r = 0;
            for (var i = 0; i < this.length; i++) {
              var b = this._zeroBits(this.words[i]);
              r += b;
              if (b !== 26) break;
            }
            return r;
          };
          BN.prototype.byteLength = function byteLength() {
            return Math.ceil(this.bitLength() / 8);
          };
          BN.prototype.toTwos = function toTwos(width) {
            if (this.negative !== 0) {
              return this.abs().inotn(width).iaddn(1);
            }
            return this.clone();
          };
          BN.prototype.fromTwos = function fromTwos(width) {
            if (this.testn(width - 1)) {
              return this.notn(width).iaddn(1).ineg();
            }
            return this.clone();
          };
          BN.prototype.isNeg = function isNeg() {
            return this.negative !== 0;
          };
          BN.prototype.neg = function neg() {
            return this.clone().ineg();
          };
          BN.prototype.ineg = function ineg() {
            if (!this.isZero()) {
              this.negative ^= 1;
            }
            return this;
          };
          BN.prototype.iuor = function iuor(num) {
            while (this.length < num.length) {
              this.words[this.length++] = 0;
            }
            for (var i = 0; i < num.length; i++) {
              this.words[i] = this.words[i] | num.words[i];
            }
            return this.strip();
          };
          BN.prototype.ior = function ior(num) {
            assert((this.negative | num.negative) === 0);
            return this.iuor(num);
          };
          BN.prototype.or = function or(num) {
            if (this.length > num.length) return this.clone().ior(num);
            return num.clone().ior(this);
          };
          BN.prototype.uor = function uor(num) {
            if (this.length > num.length) return this.clone().iuor(num);
            return num.clone().iuor(this);
          };
          BN.prototype.iuand = function iuand(num) {
            var b;
            if (this.length > num.length) {
              b = num;
            } else {
              b = this;
            }
            for (var i = 0; i < b.length; i++) {
              this.words[i] = this.words[i] & num.words[i];
            }
            this.length = b.length;
            return this.strip();
          };
          BN.prototype.iand = function iand(num) {
            assert((this.negative | num.negative) === 0);
            return this.iuand(num);
          };
          BN.prototype.and = function and(num) {
            if (this.length > num.length) return this.clone().iand(num);
            return num.clone().iand(this);
          };
          BN.prototype.uand = function uand(num) {
            if (this.length > num.length) return this.clone().iuand(num);
            return num.clone().iuand(this);
          };
          BN.prototype.iuxor = function iuxor(num) {
            var a;
            var b;
            if (this.length > num.length) {
              a = this;
              b = num;
            } else {
              a = num;
              b = this;
            }
            for (var i = 0; i < b.length; i++) {
              this.words[i] = a.words[i] ^ b.words[i];
            }
            if (this !== a) {
              for (; i < a.length; i++) {
                this.words[i] = a.words[i];
              }
            }
            this.length = a.length;
            return this.strip();
          };
          BN.prototype.ixor = function ixor(num) {
            assert((this.negative | num.negative) === 0);
            return this.iuxor(num);
          };
          BN.prototype.xor = function xor(num) {
            if (this.length > num.length) return this.clone().ixor(num);
            return num.clone().ixor(this);
          };
          BN.prototype.uxor = function uxor(num) {
            if (this.length > num.length) return this.clone().iuxor(num);
            return num.clone().iuxor(this);
          };
          BN.prototype.inotn = function inotn(width) {
            assert(typeof width === "number" && width >= 0);
            var bytesNeeded = Math.ceil(width / 26) | 0;
            var bitsLeft = width % 26;
            this._expand(bytesNeeded);
            if (bitsLeft > 0) {
              bytesNeeded--;
            }
            for (var i = 0; i < bytesNeeded; i++) {
              this.words[i] = ~this.words[i] & 67108863;
            }
            if (bitsLeft > 0) {
              this.words[i] = ~this.words[i] & (67108863 >> (26 - bitsLeft));
            }
            return this.strip();
          };
          BN.prototype.notn = function notn(width) {
            return this.clone().inotn(width);
          };
          BN.prototype.setn = function setn(bit, val) {
            assert(typeof bit === "number" && bit >= 0);
            var off = (bit / 26) | 0;
            var wbit = bit % 26;
            this._expand(off + 1);
            if (val) {
              this.words[off] = this.words[off] | (1 << wbit);
            } else {
              this.words[off] = this.words[off] & ~(1 << wbit);
            }
            return this.strip();
          };
          BN.prototype.iadd = function iadd(num) {
            var r;
            if (this.negative !== 0 && num.negative === 0) {
              this.negative = 0;
              r = this.isub(num);
              this.negative ^= 1;
              return this._normSign();
            } else if (this.negative === 0 && num.negative !== 0) {
              num.negative = 0;
              r = this.isub(num);
              num.negative = 1;
              return r._normSign();
            }
            var a, b;
            if (this.length > num.length) {
              a = this;
              b = num;
            } else {
              a = num;
              b = this;
            }
            var carry = 0;
            for (var i = 0; i < b.length; i++) {
              r = (a.words[i] | 0) + (b.words[i] | 0) + carry;
              this.words[i] = r & 67108863;
              carry = r >>> 26;
            }
            for (; carry !== 0 && i < a.length; i++) {
              r = (a.words[i] | 0) + carry;
              this.words[i] = r & 67108863;
              carry = r >>> 26;
            }
            this.length = a.length;
            if (carry !== 0) {
              this.words[this.length] = carry;
              this.length++;
            } else if (a !== this) {
              for (; i < a.length; i++) {
                this.words[i] = a.words[i];
              }
            }
            return this;
          };
          BN.prototype.add = function add(num) {
            var res;
            if (num.negative !== 0 && this.negative === 0) {
              num.negative = 0;
              res = this.sub(num);
              num.negative ^= 1;
              return res;
            } else if (num.negative === 0 && this.negative !== 0) {
              this.negative = 0;
              res = num.sub(this);
              this.negative = 1;
              return res;
            }
            if (this.length > num.length) return this.clone().iadd(num);
            return num.clone().iadd(this);
          };
          BN.prototype.isub = function isub(num) {
            if (num.negative !== 0) {
              num.negative = 0;
              var r = this.iadd(num);
              num.negative = 1;
              return r._normSign();
            } else if (this.negative !== 0) {
              this.negative = 0;
              this.iadd(num);
              this.negative = 1;
              return this._normSign();
            }
            var cmp = this.cmp(num);
            if (cmp === 0) {
              this.negative = 0;
              this.length = 1;
              this.words[0] = 0;
              return this;
            }
            var a, b;
            if (cmp > 0) {
              a = this;
              b = num;
            } else {
              a = num;
              b = this;
            }
            var carry = 0;
            for (var i = 0; i < b.length; i++) {
              r = (a.words[i] | 0) - (b.words[i] | 0) + carry;
              carry = r >> 26;
              this.words[i] = r & 67108863;
            }
            for (; carry !== 0 && i < a.length; i++) {
              r = (a.words[i] | 0) + carry;
              carry = r >> 26;
              this.words[i] = r & 67108863;
            }
            if (carry === 0 && i < a.length && a !== this) {
              for (; i < a.length; i++) {
                this.words[i] = a.words[i];
              }
            }
            this.length = Math.max(this.length, i);
            if (a !== this) {
              this.negative = 1;
            }
            return this.strip();
          };
          BN.prototype.sub = function sub(num) {
            return this.clone().isub(num);
          };
          function smallMulTo(self, num, out) {
            out.negative = num.negative ^ self.negative;
            var len = (self.length + num.length) | 0;
            out.length = len;
            len = (len - 1) | 0;
            var a = self.words[0] | 0;
            var b = num.words[0] | 0;
            var r = a * b;
            var lo = r & 67108863;
            var carry = (r / 67108864) | 0;
            out.words[0] = lo;
            for (var k = 1; k < len; k++) {
              var ncarry = carry >>> 26;
              var rword = carry & 67108863;
              var maxJ = Math.min(k, num.length - 1);
              for (var j = Math.max(0, k - self.length + 1); j <= maxJ; j++) {
                var i = (k - j) | 0;
                a = self.words[i] | 0;
                b = num.words[j] | 0;
                r = a * b + rword;
                ncarry += (r / 67108864) | 0;
                rword = r & 67108863;
              }
              out.words[k] = rword | 0;
              carry = ncarry | 0;
            }
            if (carry !== 0) {
              out.words[k] = carry | 0;
            } else {
              out.length--;
            }
            return out.strip();
          }
          var comb10MulTo = function comb10MulTo(self, num, out) {
            var a = self.words;
            var b = num.words;
            var o = out.words;
            var c = 0;
            var lo;
            var mid;
            var hi;
            var a0 = a[0] | 0;
            var al0 = a0 & 8191;
            var ah0 = a0 >>> 13;
            var a1 = a[1] | 0;
            var al1 = a1 & 8191;
            var ah1 = a1 >>> 13;
            var a2 = a[2] | 0;
            var al2 = a2 & 8191;
            var ah2 = a2 >>> 13;
            var a3 = a[3] | 0;
            var al3 = a3 & 8191;
            var ah3 = a3 >>> 13;
            var a4 = a[4] | 0;
            var al4 = a4 & 8191;
            var ah4 = a4 >>> 13;
            var a5 = a[5] | 0;
            var al5 = a5 & 8191;
            var ah5 = a5 >>> 13;
            var a6 = a[6] | 0;
            var al6 = a6 & 8191;
            var ah6 = a6 >>> 13;
            var a7 = a[7] | 0;
            var al7 = a7 & 8191;
            var ah7 = a7 >>> 13;
            var a8 = a[8] | 0;
            var al8 = a8 & 8191;
            var ah8 = a8 >>> 13;
            var a9 = a[9] | 0;
            var al9 = a9 & 8191;
            var ah9 = a9 >>> 13;
            var b0 = b[0] | 0;
            var bl0 = b0 & 8191;
            var bh0 = b0 >>> 13;
            var b1 = b[1] | 0;
            var bl1 = b1 & 8191;
            var bh1 = b1 >>> 13;
            var b2 = b[2] | 0;
            var bl2 = b2 & 8191;
            var bh2 = b2 >>> 13;
            var b3 = b[3] | 0;
            var bl3 = b3 & 8191;
            var bh3 = b3 >>> 13;
            var b4 = b[4] | 0;
            var bl4 = b4 & 8191;
            var bh4 = b4 >>> 13;
            var b5 = b[5] | 0;
            var bl5 = b5 & 8191;
            var bh5 = b5 >>> 13;
            var b6 = b[6] | 0;
            var bl6 = b6 & 8191;
            var bh6 = b6 >>> 13;
            var b7 = b[7] | 0;
            var bl7 = b7 & 8191;
            var bh7 = b7 >>> 13;
            var b8 = b[8] | 0;
            var bl8 = b8 & 8191;
            var bh8 = b8 >>> 13;
            var b9 = b[9] | 0;
            var bl9 = b9 & 8191;
            var bh9 = b9 >>> 13;
            out.negative = self.negative ^ num.negative;
            out.length = 19;
            lo = Math.imul(al0, bl0);
            mid = Math.imul(al0, bh0);
            mid = (mid + Math.imul(ah0, bl0)) | 0;
            hi = Math.imul(ah0, bh0);
            var w0 = (((c + lo) | 0) + ((mid & 8191) << 13)) | 0;
            c = (((hi + (mid >>> 13)) | 0) + (w0 >>> 26)) | 0;
            w0 &= 67108863;
            lo = Math.imul(al1, bl0);
            mid = Math.imul(al1, bh0);
            mid = (mid + Math.imul(ah1, bl0)) | 0;
            hi = Math.imul(ah1, bh0);
            lo = (lo + Math.imul(al0, bl1)) | 0;
            mid = (mid + Math.imul(al0, bh1)) | 0;
            mid = (mid + Math.imul(ah0, bl1)) | 0;
            hi = (hi + Math.imul(ah0, bh1)) | 0;
            var w1 = (((c + lo) | 0) + ((mid & 8191) << 13)) | 0;
            c = (((hi + (mid >>> 13)) | 0) + (w1 >>> 26)) | 0;
            w1 &= 67108863;
            lo = Math.imul(al2, bl0);
            mid = Math.imul(al2, bh0);
            mid = (mid + Math.imul(ah2, bl0)) | 0;
            hi = Math.imul(ah2, bh0);
            lo = (lo + Math.imul(al1, bl1)) | 0;
            mid = (mid + Math.imul(al1, bh1)) | 0;
            mid = (mid + Math.imul(ah1, bl1)) | 0;
            hi = (hi + Math.imul(ah1, bh1)) | 0;
            lo = (lo + Math.imul(al0, bl2)) | 0;
            mid = (mid + Math.imul(al0, bh2)) | 0;
            mid = (mid + Math.imul(ah0, bl2)) | 0;
            hi = (hi + Math.imul(ah0, bh2)) | 0;
            var w2 = (((c + lo) | 0) + ((mid & 8191) << 13)) | 0;
            c = (((hi + (mid >>> 13)) | 0) + (w2 >>> 26)) | 0;
            w2 &= 67108863;
            lo = Math.imul(al3, bl0);
            mid = Math.imul(al3, bh0);
            mid = (mid + Math.imul(ah3, bl0)) | 0;
            hi = Math.imul(ah3, bh0);
            lo = (lo + Math.imul(al2, bl1)) | 0;
            mid = (mid + Math.imul(al2, bh1)) | 0;
            mid = (mid + Math.imul(ah2, bl1)) | 0;
            hi = (hi + Math.imul(ah2, bh1)) | 0;
            lo = (lo + Math.imul(al1, bl2)) | 0;
            mid = (mid + Math.imul(al1, bh2)) | 0;
            mid = (mid + Math.imul(ah1, bl2)) | 0;
            hi = (hi + Math.imul(ah1, bh2)) | 0;
            lo = (lo + Math.imul(al0, bl3)) | 0;
            mid = (mid + Math.imul(al0, bh3)) | 0;
            mid = (mid + Math.imul(ah0, bl3)) | 0;
            hi = (hi + Math.imul(ah0, bh3)) | 0;
            var w3 = (((c + lo) | 0) + ((mid & 8191) << 13)) | 0;
            c = (((hi + (mid >>> 13)) | 0) + (w3 >>> 26)) | 0;
            w3 &= 67108863;
            lo = Math.imul(al4, bl0);
            mid = Math.imul(al4, bh0);
            mid = (mid + Math.imul(ah4, bl0)) | 0;
            hi = Math.imul(ah4, bh0);
            lo = (lo + Math.imul(al3, bl1)) | 0;
            mid = (mid + Math.imul(al3, bh1)) | 0;
            mid = (mid + Math.imul(ah3, bl1)) | 0;
            hi = (hi + Math.imul(ah3, bh1)) | 0;
            lo = (lo + Math.imul(al2, bl2)) | 0;
            mid = (mid + Math.imul(al2, bh2)) | 0;
            mid = (mid + Math.imul(ah2, bl2)) | 0;
            hi = (hi + Math.imul(ah2, bh2)) | 0;
            lo = (lo + Math.imul(al1, bl3)) | 0;
            mid = (mid + Math.imul(al1, bh3)) | 0;
            mid = (mid + Math.imul(ah1, bl3)) | 0;
            hi = (hi + Math.imul(ah1, bh3)) | 0;
            lo = (lo + Math.imul(al0, bl4)) | 0;
            mid = (mid + Math.imul(al0, bh4)) | 0;
            mid = (mid + Math.imul(ah0, bl4)) | 0;
            hi = (hi + Math.imul(ah0, bh4)) | 0;
            var w4 = (((c + lo) | 0) + ((mid & 8191) << 13)) | 0;
            c = (((hi + (mid >>> 13)) | 0) + (w4 >>> 26)) | 0;
            w4 &= 67108863;
            lo = Math.imul(al5, bl0);
            mid = Math.imul(al5, bh0);
            mid = (mid + Math.imul(ah5, bl0)) | 0;
            hi = Math.imul(ah5, bh0);
            lo = (lo + Math.imul(al4, bl1)) | 0;
            mid = (mid + Math.imul(al4, bh1)) | 0;
            mid = (mid + Math.imul(ah4, bl1)) | 0;
            hi = (hi + Math.imul(ah4, bh1)) | 0;
            lo = (lo + Math.imul(al3, bl2)) | 0;
            mid = (mid + Math.imul(al3, bh2)) | 0;
            mid = (mid + Math.imul(ah3, bl2)) | 0;
            hi = (hi + Math.imul(ah3, bh2)) | 0;
            lo = (lo + Math.imul(al2, bl3)) | 0;
            mid = (mid + Math.imul(al2, bh3)) | 0;
            mid = (mid + Math.imul(ah2, bl3)) | 0;
            hi = (hi + Math.imul(ah2, bh3)) | 0;
            lo = (lo + Math.imul(al1, bl4)) | 0;
            mid = (mid + Math.imul(al1, bh4)) | 0;
            mid = (mid + Math.imul(ah1, bl4)) | 0;
            hi = (hi + Math.imul(ah1, bh4)) | 0;
            lo = (lo + Math.imul(al0, bl5)) | 0;
            mid = (mid + Math.imul(al0, bh5)) | 0;
            mid = (mid + Math.imul(ah0, bl5)) | 0;
            hi = (hi + Math.imul(ah0, bh5)) | 0;
            var w5 = (((c + lo) | 0) + ((mid & 8191) << 13)) | 0;
            c = (((hi + (mid >>> 13)) | 0) + (w5 >>> 26)) | 0;
            w5 &= 67108863;
            lo = Math.imul(al6, bl0);
            mid = Math.imul(al6, bh0);
            mid = (mid + Math.imul(ah6, bl0)) | 0;
            hi = Math.imul(ah6, bh0);
            lo = (lo + Math.imul(al5, bl1)) | 0;
            mid = (mid + Math.imul(al5, bh1)) | 0;
            mid = (mid + Math.imul(ah5, bl1)) | 0;
            hi = (hi + Math.imul(ah5, bh1)) | 0;
            lo = (lo + Math.imul(al4, bl2)) | 0;
            mid = (mid + Math.imul(al4, bh2)) | 0;
            mid = (mid + Math.imul(ah4, bl2)) | 0;
            hi = (hi + Math.imul(ah4, bh2)) | 0;
            lo = (lo + Math.imul(al3, bl3)) | 0;
            mid = (mid + Math.imul(al3, bh3)) | 0;
            mid = (mid + Math.imul(ah3, bl3)) | 0;
            hi = (hi + Math.imul(ah3, bh3)) | 0;
            lo = (lo + Math.imul(al2, bl4)) | 0;
            mid = (mid + Math.imul(al2, bh4)) | 0;
            mid = (mid + Math.imul(ah2, bl4)) | 0;
            hi = (hi + Math.imul(ah2, bh4)) | 0;
            lo = (lo + Math.imul(al1, bl5)) | 0;
            mid = (mid + Math.imul(al1, bh5)) | 0;
            mid = (mid + Math.imul(ah1, bl5)) | 0;
            hi = (hi + Math.imul(ah1, bh5)) | 0;
            lo = (lo + Math.imul(al0, bl6)) | 0;
            mid = (mid + Math.imul(al0, bh6)) | 0;
            mid = (mid + Math.imul(ah0, bl6)) | 0;
            hi = (hi + Math.imul(ah0, bh6)) | 0;
            var w6 = (((c + lo) | 0) + ((mid & 8191) << 13)) | 0;
            c = (((hi + (mid >>> 13)) | 0) + (w6 >>> 26)) | 0;
            w6 &= 67108863;
            lo = Math.imul(al7, bl0);
            mid = Math.imul(al7, bh0);
            mid = (mid + Math.imul(ah7, bl0)) | 0;
            hi = Math.imul(ah7, bh0);
            lo = (lo + Math.imul(al6, bl1)) | 0;
            mid = (mid + Math.imul(al6, bh1)) | 0;
            mid = (mid + Math.imul(ah6, bl1)) | 0;
            hi = (hi + Math.imul(ah6, bh1)) | 0;
            lo = (lo + Math.imul(al5, bl2)) | 0;
            mid = (mid + Math.imul(al5, bh2)) | 0;
            mid = (mid + Math.imul(ah5, bl2)) | 0;
            hi = (hi + Math.imul(ah5, bh2)) | 0;
            lo = (lo + Math.imul(al4, bl3)) | 0;
            mid = (mid + Math.imul(al4, bh3)) | 0;
            mid = (mid + Math.imul(ah4, bl3)) | 0;
            hi = (hi + Math.imul(ah4, bh3)) | 0;
            lo = (lo + Math.imul(al3, bl4)) | 0;
            mid = (mid + Math.imul(al3, bh4)) | 0;
            mid = (mid + Math.imul(ah3, bl4)) | 0;
            hi = (hi + Math.imul(ah3, bh4)) | 0;
            lo = (lo + Math.imul(al2, bl5)) | 0;
            mid = (mid + Math.imul(al2, bh5)) | 0;
            mid = (mid + Math.imul(ah2, bl5)) | 0;
            hi = (hi + Math.imul(ah2, bh5)) | 0;
            lo = (lo + Math.imul(al1, bl6)) | 0;
            mid = (mid + Math.imul(al1, bh6)) | 0;
            mid = (mid + Math.imul(ah1, bl6)) | 0;
            hi = (hi + Math.imul(ah1, bh6)) | 0;
            lo = (lo + Math.imul(al0, bl7)) | 0;
            mid = (mid + Math.imul(al0, bh7)) | 0;
            mid = (mid + Math.imul(ah0, bl7)) | 0;
            hi = (hi + Math.imul(ah0, bh7)) | 0;
            var w7 = (((c + lo) | 0) + ((mid & 8191) << 13)) | 0;
            c = (((hi + (mid >>> 13)) | 0) + (w7 >>> 26)) | 0;
            w7 &= 67108863;
            lo = Math.imul(al8, bl0);
            mid = Math.imul(al8, bh0);
            mid = (mid + Math.imul(ah8, bl0)) | 0;
            hi = Math.imul(ah8, bh0);
            lo = (lo + Math.imul(al7, bl1)) | 0;
            mid = (mid + Math.imul(al7, bh1)) | 0;
            mid = (mid + Math.imul(ah7, bl1)) | 0;
            hi = (hi + Math.imul(ah7, bh1)) | 0;
            lo = (lo + Math.imul(al6, bl2)) | 0;
            mid = (mid + Math.imul(al6, bh2)) | 0;
            mid = (mid + Math.imul(ah6, bl2)) | 0;
            hi = (hi + Math.imul(ah6, bh2)) | 0;
            lo = (lo + Math.imul(al5, bl3)) | 0;
            mid = (mid + Math.imul(al5, bh3)) | 0;
            mid = (mid + Math.imul(ah5, bl3)) | 0;
            hi = (hi + Math.imul(ah5, bh3)) | 0;
            lo = (lo + Math.imul(al4, bl4)) | 0;
            mid = (mid + Math.imul(al4, bh4)) | 0;
            mid = (mid + Math.imul(ah4, bl4)) | 0;
            hi = (hi + Math.imul(ah4, bh4)) | 0;
            lo = (lo + Math.imul(al3, bl5)) | 0;
            mid = (mid + Math.imul(al3, bh5)) | 0;
            mid = (mid + Math.imul(ah3, bl5)) | 0;
            hi = (hi + Math.imul(ah3, bh5)) | 0;
            lo = (lo + Math.imul(al2, bl6)) | 0;
            mid = (mid + Math.imul(al2, bh6)) | 0;
            mid = (mid + Math.imul(ah2, bl6)) | 0;
            hi = (hi + Math.imul(ah2, bh6)) | 0;
            lo = (lo + Math.imul(al1, bl7)) | 0;
            mid = (mid + Math.imul(al1, bh7)) | 0;
            mid = (mid + Math.imul(ah1, bl7)) | 0;
            hi = (hi + Math.imul(ah1, bh7)) | 0;
            lo = (lo + Math.imul(al0, bl8)) | 0;
            mid = (mid + Math.imul(al0, bh8)) | 0;
            mid = (mid + Math.imul(ah0, bl8)) | 0;
            hi = (hi + Math.imul(ah0, bh8)) | 0;
            var w8 = (((c + lo) | 0) + ((mid & 8191) << 13)) | 0;
            c = (((hi + (mid >>> 13)) | 0) + (w8 >>> 26)) | 0;
            w8 &= 67108863;
            lo = Math.imul(al9, bl0);
            mid = Math.imul(al9, bh0);
            mid = (mid + Math.imul(ah9, bl0)) | 0;
            hi = Math.imul(ah9, bh0);
            lo = (lo + Math.imul(al8, bl1)) | 0;
            mid = (mid + Math.imul(al8, bh1)) | 0;
            mid = (mid + Math.imul(ah8, bl1)) | 0;
            hi = (hi + Math.imul(ah8, bh1)) | 0;
            lo = (lo + Math.imul(al7, bl2)) | 0;
            mid = (mid + Math.imul(al7, bh2)) | 0;
            mid = (mid + Math.imul(ah7, bl2)) | 0;
            hi = (hi + Math.imul(ah7, bh2)) | 0;
            lo = (lo + Math.imul(al6, bl3)) | 0;
            mid = (mid + Math.imul(al6, bh3)) | 0;
            mid = (mid + Math.imul(ah6, bl3)) | 0;
            hi = (hi + Math.imul(ah6, bh3)) | 0;
            lo = (lo + Math.imul(al5, bl4)) | 0;
            mid = (mid + Math.imul(al5, bh4)) | 0;
            mid = (mid + Math.imul(ah5, bl4)) | 0;
            hi = (hi + Math.imul(ah5, bh4)) | 0;
            lo = (lo + Math.imul(al4, bl5)) | 0;
            mid = (mid + Math.imul(al4, bh5)) | 0;
            mid = (mid + Math.imul(ah4, bl5)) | 0;
            hi = (hi + Math.imul(ah4, bh5)) | 0;
            lo = (lo + Math.imul(al3, bl6)) | 0;
            mid = (mid + Math.imul(al3, bh6)) | 0;
            mid = (mid + Math.imul(ah3, bl6)) | 0;
            hi = (hi + Math.imul(ah3, bh6)) | 0;
            lo = (lo + Math.imul(al2, bl7)) | 0;
            mid = (mid + Math.imul(al2, bh7)) | 0;
            mid = (mid + Math.imul(ah2, bl7)) | 0;
            hi = (hi + Math.imul(ah2, bh7)) | 0;
            lo = (lo + Math.imul(al1, bl8)) | 0;
            mid = (mid + Math.imul(al1, bh8)) | 0;
            mid = (mid + Math.imul(ah1, bl8)) | 0;
            hi = (hi + Math.imul(ah1, bh8)) | 0;
            lo = (lo + Math.imul(al0, bl9)) | 0;
            mid = (mid + Math.imul(al0, bh9)) | 0;
            mid = (mid + Math.imul(ah0, bl9)) | 0;
            hi = (hi + Math.imul(ah0, bh9)) | 0;
            var w9 = (((c + lo) | 0) + ((mid & 8191) << 13)) | 0;
            c = (((hi + (mid >>> 13)) | 0) + (w9 >>> 26)) | 0;
            w9 &= 67108863;
            lo = Math.imul(al9, bl1);
            mid = Math.imul(al9, bh1);
            mid = (mid + Math.imul(ah9, bl1)) | 0;
            hi = Math.imul(ah9, bh1);
            lo = (lo + Math.imul(al8, bl2)) | 0;
            mid = (mid + Math.imul(al8, bh2)) | 0;
            mid = (mid + Math.imul(ah8, bl2)) | 0;
            hi = (hi + Math.imul(ah8, bh2)) | 0;
            lo = (lo + Math.imul(al7, bl3)) | 0;
            mid = (mid + Math.imul(al7, bh3)) | 0;
            mid = (mid + Math.imul(ah7, bl3)) | 0;
            hi = (hi + Math.imul(ah7, bh3)) | 0;
            lo = (lo + Math.imul(al6, bl4)) | 0;
            mid = (mid + Math.imul(al6, bh4)) | 0;
            mid = (mid + Math.imul(ah6, bl4)) | 0;
            hi = (hi + Math.imul(ah6, bh4)) | 0;
            lo = (lo + Math.imul(al5, bl5)) | 0;
            mid = (mid + Math.imul(al5, bh5)) | 0;
            mid = (mid + Math.imul(ah5, bl5)) | 0;
            hi = (hi + Math.imul(ah5, bh5)) | 0;
            lo = (lo + Math.imul(al4, bl6)) | 0;
            mid = (mid + Math.imul(al4, bh6)) | 0;
            mid = (mid + Math.imul(ah4, bl6)) | 0;
            hi = (hi + Math.imul(ah4, bh6)) | 0;
            lo = (lo + Math.imul(al3, bl7)) | 0;
            mid = (mid + Math.imul(al3, bh7)) | 0;
            mid = (mid + Math.imul(ah3, bl7)) | 0;
            hi = (hi + Math.imul(ah3, bh7)) | 0;
            lo = (lo + Math.imul(al2, bl8)) | 0;
            mid = (mid + Math.imul(al2, bh8)) | 0;
            mid = (mid + Math.imul(ah2, bl8)) | 0;
            hi = (hi + Math.imul(ah2, bh8)) | 0;
            lo = (lo + Math.imul(al1, bl9)) | 0;
            mid = (mid + Math.imul(al1, bh9)) | 0;
            mid = (mid + Math.imul(ah1, bl9)) | 0;
            hi = (hi + Math.imul(ah1, bh9)) | 0;
            var w10 = (((c + lo) | 0) + ((mid & 8191) << 13)) | 0;
            c = (((hi + (mid >>> 13)) | 0) + (w10 >>> 26)) | 0;
            w10 &= 67108863;
            lo = Math.imul(al9, bl2);
            mid = Math.imul(al9, bh2);
            mid = (mid + Math.imul(ah9, bl2)) | 0;
            hi = Math.imul(ah9, bh2);
            lo = (lo + Math.imul(al8, bl3)) | 0;
            mid = (mid + Math.imul(al8, bh3)) | 0;
            mid = (mid + Math.imul(ah8, bl3)) | 0;
            hi = (hi + Math.imul(ah8, bh3)) | 0;
            lo = (lo + Math.imul(al7, bl4)) | 0;
            mid = (mid + Math.imul(al7, bh4)) | 0;
            mid = (mid + Math.imul(ah7, bl4)) | 0;
            hi = (hi + Math.imul(ah7, bh4)) | 0;
            lo = (lo + Math.imul(al6, bl5)) | 0;
            mid = (mid + Math.imul(al6, bh5)) | 0;
            mid = (mid + Math.imul(ah6, bl5)) | 0;
            hi = (hi + Math.imul(ah6, bh5)) | 0;
            lo = (lo + Math.imul(al5, bl6)) | 0;
            mid = (mid + Math.imul(al5, bh6)) | 0;
            mid = (mid + Math.imul(ah5, bl6)) | 0;
            hi = (hi + Math.imul(ah5, bh6)) | 0;
            lo = (lo + Math.imul(al4, bl7)) | 0;
            mid = (mid + Math.imul(al4, bh7)) | 0;
            mid = (mid + Math.imul(ah4, bl7)) | 0;
            hi = (hi + Math.imul(ah4, bh7)) | 0;
            lo = (lo + Math.imul(al3, bl8)) | 0;
            mid = (mid + Math.imul(al3, bh8)) | 0;
            mid = (mid + Math.imul(ah3, bl8)) | 0;
            hi = (hi + Math.imul(ah3, bh8)) | 0;
            lo = (lo + Math.imul(al2, bl9)) | 0;
            mid = (mid + Math.imul(al2, bh9)) | 0;
            mid = (mid + Math.imul(ah2, bl9)) | 0;
            hi = (hi + Math.imul(ah2, bh9)) | 0;
            var w11 = (((c + lo) | 0) + ((mid & 8191) << 13)) | 0;
            c = (((hi + (mid >>> 13)) | 0) + (w11 >>> 26)) | 0;
            w11 &= 67108863;
            lo = Math.imul(al9, bl3);
            mid = Math.imul(al9, bh3);
            mid = (mid + Math.imul(ah9, bl3)) | 0;
            hi = Math.imul(ah9, bh3);
            lo = (lo + Math.imul(al8, bl4)) | 0;
            mid = (mid + Math.imul(al8, bh4)) | 0;
            mid = (mid + Math.imul(ah8, bl4)) | 0;
            hi = (hi + Math.imul(ah8, bh4)) | 0;
            lo = (lo + Math.imul(al7, bl5)) | 0;
            mid = (mid + Math.imul(al7, bh5)) | 0;
            mid = (mid + Math.imul(ah7, bl5)) | 0;
            hi = (hi + Math.imul(ah7, bh5)) | 0;
            lo = (lo + Math.imul(al6, bl6)) | 0;
            mid = (mid + Math.imul(al6, bh6)) | 0;
            mid = (mid + Math.imul(ah6, bl6)) | 0;
            hi = (hi + Math.imul(ah6, bh6)) | 0;
            lo = (lo + Math.imul(al5, bl7)) | 0;
            mid = (mid + Math.imul(al5, bh7)) | 0;
            mid = (mid + Math.imul(ah5, bl7)) | 0;
            hi = (hi + Math.imul(ah5, bh7)) | 0;
            lo = (lo + Math.imul(al4, bl8)) | 0;
            mid = (mid + Math.imul(al4, bh8)) | 0;
            mid = (mid + Math.imul(ah4, bl8)) | 0;
            hi = (hi + Math.imul(ah4, bh8)) | 0;
            lo = (lo + Math.imul(al3, bl9)) | 0;
            mid = (mid + Math.imul(al3, bh9)) | 0;
            mid = (mid + Math.imul(ah3, bl9)) | 0;
            hi = (hi + Math.imul(ah3, bh9)) | 0;
            var w12 = (((c + lo) | 0) + ((mid & 8191) << 13)) | 0;
            c = (((hi + (mid >>> 13)) | 0) + (w12 >>> 26)) | 0;
            w12 &= 67108863;
            lo = Math.imul(al9, bl4);
            mid = Math.imul(al9, bh4);
            mid = (mid + Math.imul(ah9, bl4)) | 0;
            hi = Math.imul(ah9, bh4);
            lo = (lo + Math.imul(al8, bl5)) | 0;
            mid = (mid + Math.imul(al8, bh5)) | 0;
            mid = (mid + Math.imul(ah8, bl5)) | 0;
            hi = (hi + Math.imul(ah8, bh5)) | 0;
            lo = (lo + Math.imul(al7, bl6)) | 0;
            mid = (mid + Math.imul(al7, bh6)) | 0;
            mid = (mid + Math.imul(ah7, bl6)) | 0;
            hi = (hi + Math.imul(ah7, bh6)) | 0;
            lo = (lo + Math.imul(al6, bl7)) | 0;
            mid = (mid + Math.imul(al6, bh7)) | 0;
            mid = (mid + Math.imul(ah6, bl7)) | 0;
            hi = (hi + Math.imul(ah6, bh7)) | 0;
            lo = (lo + Math.imul(al5, bl8)) | 0;
            mid = (mid + Math.imul(al5, bh8)) | 0;
            mid = (mid + Math.imul(ah5, bl8)) | 0;
            hi = (hi + Math.imul(ah5, bh8)) | 0;
            lo = (lo + Math.imul(al4, bl9)) | 0;
            mid = (mid + Math.imul(al4, bh9)) | 0;
            mid = (mid + Math.imul(ah4, bl9)) | 0;
            hi = (hi + Math.imul(ah4, bh9)) | 0;
            var w13 = (((c + lo) | 0) + ((mid & 8191) << 13)) | 0;
            c = (((hi + (mid >>> 13)) | 0) + (w13 >>> 26)) | 0;
            w13 &= 67108863;
            lo = Math.imul(al9, bl5);
            mid = Math.imul(al9, bh5);
            mid = (mid + Math.imul(ah9, bl5)) | 0;
            hi = Math.imul(ah9, bh5);
            lo = (lo + Math.imul(al8, bl6)) | 0;
            mid = (mid + Math.imul(al8, bh6)) | 0;
            mid = (mid + Math.imul(ah8, bl6)) | 0;
            hi = (hi + Math.imul(ah8, bh6)) | 0;
            lo = (lo + Math.imul(al7, bl7)) | 0;
            mid = (mid + Math.imul(al7, bh7)) | 0;
            mid = (mid + Math.imul(ah7, bl7)) | 0;
            hi = (hi + Math.imul(ah7, bh7)) | 0;
            lo = (lo + Math.imul(al6, bl8)) | 0;
            mid = (mid + Math.imul(al6, bh8)) | 0;
            mid = (mid + Math.imul(ah6, bl8)) | 0;
            hi = (hi + Math.imul(ah6, bh8)) | 0;
            lo = (lo + Math.imul(al5, bl9)) | 0;
            mid = (mid + Math.imul(al5, bh9)) | 0;
            mid = (mid + Math.imul(ah5, bl9)) | 0;
            hi = (hi + Math.imul(ah5, bh9)) | 0;
            var w14 = (((c + lo) | 0) + ((mid & 8191) << 13)) | 0;
            c = (((hi + (mid >>> 13)) | 0) + (w14 >>> 26)) | 0;
            w14 &= 67108863;
            lo = Math.imul(al9, bl6);
            mid = Math.imul(al9, bh6);
            mid = (mid + Math.imul(ah9, bl6)) | 0;
            hi = Math.imul(ah9, bh6);
            lo = (lo + Math.imul(al8, bl7)) | 0;
            mid = (mid + Math.imul(al8, bh7)) | 0;
            mid = (mid + Math.imul(ah8, bl7)) | 0;
            hi = (hi + Math.imul(ah8, bh7)) | 0;
            lo = (lo + Math.imul(al7, bl8)) | 0;
            mid = (mid + Math.imul(al7, bh8)) | 0;
            mid = (mid + Math.imul(ah7, bl8)) | 0;
            hi = (hi + Math.imul(ah7, bh8)) | 0;
            lo = (lo + Math.imul(al6, bl9)) | 0;
            mid = (mid + Math.imul(al6, bh9)) | 0;
            mid = (mid + Math.imul(ah6, bl9)) | 0;
            hi = (hi + Math.imul(ah6, bh9)) | 0;
            var w15 = (((c + lo) | 0) + ((mid & 8191) << 13)) | 0;
            c = (((hi + (mid >>> 13)) | 0) + (w15 >>> 26)) | 0;
            w15 &= 67108863;
            lo = Math.imul(al9, bl7);
            mid = Math.imul(al9, bh7);
            mid = (mid + Math.imul(ah9, bl7)) | 0;
            hi = Math.imul(ah9, bh7);
            lo = (lo + Math.imul(al8, bl8)) | 0;
            mid = (mid + Math.imul(al8, bh8)) | 0;
            mid = (mid + Math.imul(ah8, bl8)) | 0;
            hi = (hi + Math.imul(ah8, bh8)) | 0;
            lo = (lo + Math.imul(al7, bl9)) | 0;
            mid = (mid + Math.imul(al7, bh9)) | 0;
            mid = (mid + Math.imul(ah7, bl9)) | 0;
            hi = (hi + Math.imul(ah7, bh9)) | 0;
            var w16 = (((c + lo) | 0) + ((mid & 8191) << 13)) | 0;
            c = (((hi + (mid >>> 13)) | 0) + (w16 >>> 26)) | 0;
            w16 &= 67108863;
            lo = Math.imul(al9, bl8);
            mid = Math.imul(al9, bh8);
            mid = (mid + Math.imul(ah9, bl8)) | 0;
            hi = Math.imul(ah9, bh8);
            lo = (lo + Math.imul(al8, bl9)) | 0;
            mid = (mid + Math.imul(al8, bh9)) | 0;
            mid = (mid + Math.imul(ah8, bl9)) | 0;
            hi = (hi + Math.imul(ah8, bh9)) | 0;
            var w17 = (((c + lo) | 0) + ((mid & 8191) << 13)) | 0;
            c = (((hi + (mid >>> 13)) | 0) + (w17 >>> 26)) | 0;
            w17 &= 67108863;
            lo = Math.imul(al9, bl9);
            mid = Math.imul(al9, bh9);
            mid = (mid + Math.imul(ah9, bl9)) | 0;
            hi = Math.imul(ah9, bh9);
            var w18 = (((c + lo) | 0) + ((mid & 8191) << 13)) | 0;
            c = (((hi + (mid >>> 13)) | 0) + (w18 >>> 26)) | 0;
            w18 &= 67108863;
            o[0] = w0;
            o[1] = w1;
            o[2] = w2;
            o[3] = w3;
            o[4] = w4;
            o[5] = w5;
            o[6] = w6;
            o[7] = w7;
            o[8] = w8;
            o[9] = w9;
            o[10] = w10;
            o[11] = w11;
            o[12] = w12;
            o[13] = w13;
            o[14] = w14;
            o[15] = w15;
            o[16] = w16;
            o[17] = w17;
            o[18] = w18;
            if (c !== 0) {
              o[19] = c;
              out.length++;
            }
            return out;
          };
          if (!Math.imul) {
            comb10MulTo = smallMulTo;
          }
          function bigMulTo(self, num, out) {
            out.negative = num.negative ^ self.negative;
            out.length = self.length + num.length;
            var carry = 0;
            var hncarry = 0;
            for (var k = 0; k < out.length - 1; k++) {
              var ncarry = hncarry;
              hncarry = 0;
              var rword = carry & 67108863;
              var maxJ = Math.min(k, num.length - 1);
              for (var j = Math.max(0, k - self.length + 1); j <= maxJ; j++) {
                var i = k - j;
                var a = self.words[i] | 0;
                var b = num.words[j] | 0;
                var r = a * b;
                var lo = r & 67108863;
                ncarry = (ncarry + ((r / 67108864) | 0)) | 0;
                lo = (lo + rword) | 0;
                rword = lo & 67108863;
                ncarry = (ncarry + (lo >>> 26)) | 0;
                hncarry += ncarry >>> 26;
                ncarry &= 67108863;
              }
              out.words[k] = rword;
              carry = ncarry;
              ncarry = hncarry;
            }
            if (carry !== 0) {
              out.words[k] = carry;
            } else {
              out.length--;
            }
            return out.strip();
          }
          function jumboMulTo(self, num, out) {
            var fftm = new FFTM();
            return fftm.mulp(self, num, out);
          }
          BN.prototype.mulTo = function mulTo(num, out) {
            var res;
            var len = this.length + num.length;
            if (this.length === 10 && num.length === 10) {
              res = comb10MulTo(this, num, out);
            } else if (len < 63) {
              res = smallMulTo(this, num, out);
            } else if (len < 1024) {
              res = bigMulTo(this, num, out);
            } else {
              res = jumboMulTo(this, num, out);
            }
            return res;
          };
          function FFTM(x, y) {
            this.x = x;
            this.y = y;
          }
          FFTM.prototype.makeRBT = function makeRBT(N) {
            var t = new Array(N);
            var l = BN.prototype._countBits(N) - 1;
            for (var i = 0; i < N; i++) {
              t[i] = this.revBin(i, l, N);
            }
            return t;
          };
          FFTM.prototype.revBin = function revBin(x, l, N) {
            if (x === 0 || x === N - 1) return x;
            var rb = 0;
            for (var i = 0; i < l; i++) {
              rb |= (x & 1) << (l - i - 1);
              x >>= 1;
            }
            return rb;
          };
          FFTM.prototype.permute = function permute(
            rbt,
            rws,
            iws,
            rtws,
            itws,
            N
          ) {
            for (var i = 0; i < N; i++) {
              rtws[i] = rws[rbt[i]];
              itws[i] = iws[rbt[i]];
            }
          };
          FFTM.prototype.transform = function transform(
            rws,
            iws,
            rtws,
            itws,
            N,
            rbt
          ) {
            this.permute(rbt, rws, iws, rtws, itws, N);
            for (var s = 1; s < N; s <<= 1) {
              var l = s << 1;
              var rtwdf = Math.cos((2 * Math.PI) / l);
              var itwdf = Math.sin((2 * Math.PI) / l);
              for (var p = 0; p < N; p += l) {
                var rtwdf_ = rtwdf;
                var itwdf_ = itwdf;
                for (var j = 0; j < s; j++) {
                  var re = rtws[p + j];
                  var ie = itws[p + j];
                  var ro = rtws[p + j + s];
                  var io = itws[p + j + s];
                  var rx = rtwdf_ * ro - itwdf_ * io;
                  io = rtwdf_ * io + itwdf_ * ro;
                  ro = rx;
                  rtws[p + j] = re + ro;
                  itws[p + j] = ie + io;
                  rtws[p + j + s] = re - ro;
                  itws[p + j + s] = ie - io;
                  if (j !== l) {
                    rx = rtwdf * rtwdf_ - itwdf * itwdf_;
                    itwdf_ = rtwdf * itwdf_ + itwdf * rtwdf_;
                    rtwdf_ = rx;
                  }
                }
              }
            }
          };
          FFTM.prototype.guessLen13b = function guessLen13b(n, m) {
            var N = Math.max(m, n) | 1;
            var odd = N & 1;
            var i = 0;
            for (N = (N / 2) | 0; N; N = N >>> 1) {
              i++;
            }
            return 1 << (i + 1 + odd);
          };
          FFTM.prototype.conjugate = function conjugate(rws, iws, N) {
            if (N <= 1) return;
            for (var i = 0; i < N / 2; i++) {
              var t = rws[i];
              rws[i] = rws[N - i - 1];
              rws[N - i - 1] = t;
              t = iws[i];
              iws[i] = -iws[N - i - 1];
              iws[N - i - 1] = -t;
            }
          };
          FFTM.prototype.normalize13b = function normalize13b(ws, N) {
            var carry = 0;
            for (var i = 0; i < N / 2; i++) {
              var w =
                Math.round(ws[2 * i + 1] / N) * 8192 +
                Math.round(ws[2 * i] / N) +
                carry;
              ws[i] = w & 67108863;
              if (w < 67108864) {
                carry = 0;
              } else {
                carry = (w / 67108864) | 0;
              }
            }
            return ws;
          };
          FFTM.prototype.convert13b = function convert13b(ws, len, rws, N) {
            var carry = 0;
            for (var i = 0; i < len; i++) {
              carry = carry + (ws[i] | 0);
              rws[2 * i] = carry & 8191;
              carry = carry >>> 13;
              rws[2 * i + 1] = carry & 8191;
              carry = carry >>> 13;
            }
            for (i = 2 * len; i < N; ++i) {
              rws[i] = 0;
            }
            assert(carry === 0);
            assert((carry & ~8191) === 0);
          };
          FFTM.prototype.stub = function stub(N) {
            var ph = new Array(N);
            for (var i = 0; i < N; i++) {
              ph[i] = 0;
            }
            return ph;
          };
          FFTM.prototype.mulp = function mulp(x, y, out) {
            var N = 2 * this.guessLen13b(x.length, y.length);
            var rbt = this.makeRBT(N);
            var _ = this.stub(N);
            var rws = new Array(N);
            var rwst = new Array(N);
            var iwst = new Array(N);
            var nrws = new Array(N);
            var nrwst = new Array(N);
            var niwst = new Array(N);
            var rmws = out.words;
            rmws.length = N;
            this.convert13b(x.words, x.length, rws, N);
            this.convert13b(y.words, y.length, nrws, N);
            this.transform(rws, _, rwst, iwst, N, rbt);
            this.transform(nrws, _, nrwst, niwst, N, rbt);
            for (var i = 0; i < N; i++) {
              var rx = rwst[i] * nrwst[i] - iwst[i] * niwst[i];
              iwst[i] = rwst[i] * niwst[i] + iwst[i] * nrwst[i];
              rwst[i] = rx;
            }
            this.conjugate(rwst, iwst, N);
            this.transform(rwst, iwst, rmws, _, N, rbt);
            this.conjugate(rmws, _, N);
            this.normalize13b(rmws, N);
            out.negative = x.negative ^ y.negative;
            out.length = x.length + y.length;
            return out.strip();
          };
          BN.prototype.mul = function mul(num) {
            var out = new BN(null);
            out.words = new Array(this.length + num.length);
            return this.mulTo(num, out);
          };
          BN.prototype.mulf = function mulf(num) {
            var out = new BN(null);
            out.words = new Array(this.length + num.length);
            return jumboMulTo(this, num, out);
          };
          BN.prototype.imul = function imul(num) {
            return this.clone().mulTo(num, this);
          };
          BN.prototype.imuln = function imuln(num) {
            assert(typeof num === "number");
            assert(num < 67108864);
            var carry = 0;
            for (var i = 0; i < this.length; i++) {
              var w = (this.words[i] | 0) * num;
              var lo = (w & 67108863) + (carry & 67108863);
              carry >>= 26;
              carry += (w / 67108864) | 0;
              carry += lo >>> 26;
              this.words[i] = lo & 67108863;
            }
            if (carry !== 0) {
              this.words[i] = carry;
              this.length++;
            }
            return this;
          };
          BN.prototype.muln = function muln(num) {
            return this.clone().imuln(num);
          };
          BN.prototype.sqr = function sqr() {
            return this.mul(this);
          };
          BN.prototype.isqr = function isqr() {
            return this.imul(this.clone());
          };
          BN.prototype.pow = function pow(num) {
            var w = toBitArray(num);
            if (w.length === 0) return new BN(1);
            var res = this;
            for (var i = 0; i < w.length; i++, res = res.sqr()) {
              if (w[i] !== 0) break;
            }
            if (++i < w.length) {
              for (var q = res.sqr(); i < w.length; i++, q = q.sqr()) {
                if (w[i] === 0) continue;
                res = res.mul(q);
              }
            }
            return res;
          };
          BN.prototype.iushln = function iushln(bits) {
            assert(typeof bits === "number" && bits >= 0);
            var r = bits % 26;
            var s = (bits - r) / 26;
            var carryMask = (67108863 >>> (26 - r)) << (26 - r);
            var i;
            if (r !== 0) {
              var carry = 0;
              for (i = 0; i < this.length; i++) {
                var newCarry = this.words[i] & carryMask;
                var c = ((this.words[i] | 0) - newCarry) << r;
                this.words[i] = c | carry;
                carry = newCarry >>> (26 - r);
              }
              if (carry) {
                this.words[i] = carry;
                this.length++;
              }
            }
            if (s !== 0) {
              for (i = this.length - 1; i >= 0; i--) {
                this.words[i + s] = this.words[i];
              }
              for (i = 0; i < s; i++) {
                this.words[i] = 0;
              }
              this.length += s;
            }
            return this.strip();
          };
          BN.prototype.ishln = function ishln(bits) {
            assert(this.negative === 0);
            return this.iushln(bits);
          };
          BN.prototype.iushrn = function iushrn(bits, hint, extended) {
            assert(typeof bits === "number" && bits >= 0);
            var h;
            if (hint) {
              h = (hint - (hint % 26)) / 26;
            } else {
              h = 0;
            }
            var r = bits % 26;
            var s = Math.min((bits - r) / 26, this.length);
            var mask = 67108863 ^ ((67108863 >>> r) << r);
            var maskedWords = extended;
            h -= s;
            h = Math.max(0, h);
            if (maskedWords) {
              for (var i = 0; i < s; i++) {
                maskedWords.words[i] = this.words[i];
              }
              maskedWords.length = s;
            }
            if (s === 0) {
            } else if (this.length > s) {
              this.length -= s;
              for (i = 0; i < this.length; i++) {
                this.words[i] = this.words[i + s];
              }
            } else {
              this.words[0] = 0;
              this.length = 1;
            }
            var carry = 0;
            for (i = this.length - 1; i >= 0 && (carry !== 0 || i >= h); i--) {
              var word = this.words[i] | 0;
              this.words[i] = (carry << (26 - r)) | (word >>> r);
              carry = word & mask;
            }
            if (maskedWords && carry !== 0) {
              maskedWords.words[maskedWords.length++] = carry;
            }
            if (this.length === 0) {
              this.words[0] = 0;
              this.length = 1;
            }
            return this.strip();
          };
          BN.prototype.ishrn = function ishrn(bits, hint, extended) {
            assert(this.negative === 0);
            return this.iushrn(bits, hint, extended);
          };
          BN.prototype.shln = function shln(bits) {
            return this.clone().ishln(bits);
          };
          BN.prototype.ushln = function ushln(bits) {
            return this.clone().iushln(bits);
          };
          BN.prototype.shrn = function shrn(bits) {
            return this.clone().ishrn(bits);
          };
          BN.prototype.ushrn = function ushrn(bits) {
            return this.clone().iushrn(bits);
          };
          BN.prototype.testn = function testn(bit) {
            assert(typeof bit === "number" && bit >= 0);
            var r = bit % 26;
            var s = (bit - r) / 26;
            var q = 1 << r;
            if (this.length <= s) return false;
            var w = this.words[s];
            return !!(w & q);
          };
          BN.prototype.imaskn = function imaskn(bits) {
            assert(typeof bits === "number" && bits >= 0);
            var r = bits % 26;
            var s = (bits - r) / 26;
            assert(
              this.negative === 0,
              "imaskn works only with positive numbers"
            );
            if (this.length <= s) {
              return this;
            }
            if (r !== 0) {
              s++;
            }
            this.length = Math.min(s, this.length);
            if (r !== 0) {
              var mask = 67108863 ^ ((67108863 >>> r) << r);
              this.words[this.length - 1] &= mask;
            }
            return this.strip();
          };
          BN.prototype.maskn = function maskn(bits) {
            return this.clone().imaskn(bits);
          };
          BN.prototype.iaddn = function iaddn(num) {
            assert(typeof num === "number");
            assert(num < 67108864);
            if (num < 0) return this.isubn(-num);
            if (this.negative !== 0) {
              if (this.length === 1 && (this.words[0] | 0) < num) {
                this.words[0] = num - (this.words[0] | 0);
                this.negative = 0;
                return this;
              }
              this.negative = 0;
              this.isubn(num);
              this.negative = 1;
              return this;
            }
            return this._iaddn(num);
          };
          BN.prototype._iaddn = function _iaddn(num) {
            this.words[0] += num;
            for (var i = 0; i < this.length && this.words[i] >= 67108864; i++) {
              this.words[i] -= 67108864;
              if (i === this.length - 1) {
                this.words[i + 1] = 1;
              } else {
                this.words[i + 1]++;
              }
            }
            this.length = Math.max(this.length, i + 1);
            return this;
          };
          BN.prototype.isubn = function isubn(num) {
            assert(typeof num === "number");
            assert(num < 67108864);
            if (num < 0) return this.iaddn(-num);
            if (this.negative !== 0) {
              this.negative = 0;
              this.iaddn(num);
              this.negative = 1;
              return this;
            }
            this.words[0] -= num;
            if (this.length === 1 && this.words[0] < 0) {
              this.words[0] = -this.words[0];
              this.negative = 1;
            } else {
              for (var i = 0; i < this.length && this.words[i] < 0; i++) {
                this.words[i] += 67108864;
                this.words[i + 1] -= 1;
              }
            }
            return this.strip();
          };
          BN.prototype.addn = function addn(num) {
            return this.clone().iaddn(num);
          };
          BN.prototype.subn = function subn(num) {
            return this.clone().isubn(num);
          };
          BN.prototype.iabs = function iabs() {
            this.negative = 0;
            return this;
          };
          BN.prototype.abs = function abs() {
            return this.clone().iabs();
          };
          BN.prototype._ishlnsubmul = function _ishlnsubmul(num, mul, shift) {
            var len = num.length + shift;
            var i;
            this._expand(len);
            var w;
            var carry = 0;
            for (i = 0; i < num.length; i++) {
              w = (this.words[i + shift] | 0) + carry;
              var right = (num.words[i] | 0) * mul;
              w -= right & 67108863;
              carry = (w >> 26) - ((right / 67108864) | 0);
              this.words[i + shift] = w & 67108863;
            }
            for (; i < this.length - shift; i++) {
              w = (this.words[i + shift] | 0) + carry;
              carry = w >> 26;
              this.words[i + shift] = w & 67108863;
            }
            if (carry === 0) return this.strip();
            assert(carry === -1);
            carry = 0;
            for (i = 0; i < this.length; i++) {
              w = -(this.words[i] | 0) + carry;
              carry = w >> 26;
              this.words[i] = w & 67108863;
            }
            this.negative = 1;
            return this.strip();
          };
          BN.prototype._wordDiv = function _wordDiv(num, mode) {
            var shift = this.length - num.length;
            var a = this.clone();
            var b = num;
            var bhi = b.words[b.length - 1] | 0;
            var bhiBits = this._countBits(bhi);
            shift = 26 - bhiBits;
            if (shift !== 0) {
              b = b.ushln(shift);
              a.iushln(shift);
              bhi = b.words[b.length - 1] | 0;
            }
            var m = a.length - b.length;
            var q;
            if (mode !== "mod") {
              q = new BN(null);
              q.length = m + 1;
              q.words = new Array(q.length);
              for (var i = 0; i < q.length; i++) {
                q.words[i] = 0;
              }
            }
            var diff = a.clone()._ishlnsubmul(b, 1, m);
            if (diff.negative === 0) {
              a = diff;
              if (q) {
                q.words[m] = 1;
              }
            }
            for (var j = m - 1; j >= 0; j--) {
              var qj =
                (a.words[b.length + j] | 0) * 67108864 +
                (a.words[b.length + j - 1] | 0);
              qj = Math.min((qj / bhi) | 0, 67108863);
              a._ishlnsubmul(b, qj, j);
              while (a.negative !== 0) {
                qj--;
                a.negative = 0;
                a._ishlnsubmul(b, 1, j);
                if (!a.isZero()) {
                  a.negative ^= 1;
                }
              }
              if (q) {
                q.words[j] = qj;
              }
            }
            if (q) {
              q.strip();
            }
            a.strip();
            if (mode !== "div" && shift !== 0) {
              a.iushrn(shift);
            }
            return { div: q || null, mod: a };
          };
          BN.prototype.divmod = function divmod(num, mode, positive) {
            assert(!num.isZero());
            if (this.isZero()) {
              return { div: new BN(0), mod: new BN(0) };
            }
            var div, mod, res;
            if (this.negative !== 0 && num.negative === 0) {
              res = this.neg().divmod(num, mode);
              if (mode !== "mod") {
                div = res.div.neg();
              }
              if (mode !== "div") {
                mod = res.mod.neg();
                if (positive && mod.negative !== 0) {
                  mod.iadd(num);
                }
              }
              return { div: div, mod: mod };
            }
            if (this.negative === 0 && num.negative !== 0) {
              res = this.divmod(num.neg(), mode);
              if (mode !== "mod") {
                div = res.div.neg();
              }
              return { div: div, mod: res.mod };
            }
            if ((this.negative & num.negative) !== 0) {
              res = this.neg().divmod(num.neg(), mode);
              if (mode !== "div") {
                mod = res.mod.neg();
                if (positive && mod.negative !== 0) {
                  mod.isub(num);
                }
              }
              return { div: res.div, mod: mod };
            }
            if (num.length > this.length || this.cmp(num) < 0) {
              return { div: new BN(0), mod: this };
            }
            if (num.length === 1) {
              if (mode === "div") {
                return { div: this.divn(num.words[0]), mod: null };
              }
              if (mode === "mod") {
                return { div: null, mod: new BN(this.modn(num.words[0])) };
              }
              return {
                div: this.divn(num.words[0]),
                mod: new BN(this.modn(num.words[0])),
              };
            }
            return this._wordDiv(num, mode);
          };
          BN.prototype.div = function div(num) {
            return this.divmod(num, "div", false).div;
          };
          BN.prototype.mod = function mod(num) {
            return this.divmod(num, "mod", false).mod;
          };
          BN.prototype.umod = function umod(num) {
            return this.divmod(num, "mod", true).mod;
          };
          BN.prototype.divRound = function divRound(num) {
            var dm = this.divmod(num);
            if (dm.mod.isZero()) return dm.div;
            var mod = dm.div.negative !== 0 ? dm.mod.isub(num) : dm.mod;
            var half = num.ushrn(1);
            var r2 = num.andln(1);
            var cmp = mod.cmp(half);
            if (cmp < 0 || (r2 === 1 && cmp === 0)) return dm.div;
            return dm.div.negative !== 0 ? dm.div.isubn(1) : dm.div.iaddn(1);
          };
          BN.prototype.modn = function modn(num) {
            assert(num <= 67108863);
            var p = (1 << 26) % num;
            var acc = 0;
            for (var i = this.length - 1; i >= 0; i--) {
              acc = (p * acc + (this.words[i] | 0)) % num;
            }
            return acc;
          };
          BN.prototype.idivn = function idivn(num) {
            assert(num <= 67108863);
            var carry = 0;
            for (var i = this.length - 1; i >= 0; i--) {
              var w = (this.words[i] | 0) + carry * 67108864;
              this.words[i] = (w / num) | 0;
              carry = w % num;
            }
            return this.strip();
          };
          BN.prototype.divn = function divn(num) {
            return this.clone().idivn(num);
          };
          BN.prototype.egcd = function egcd(p) {
            assert(p.negative === 0);
            assert(!p.isZero());
            var x = this;
            var y = p.clone();
            if (x.negative !== 0) {
              x = x.umod(p);
            } else {
              x = x.clone();
            }
            var A = new BN(1);
            var B = new BN(0);
            var C = new BN(0);
            var D = new BN(1);
            var g = 0;
            while (x.isEven() && y.isEven()) {
              x.iushrn(1);
              y.iushrn(1);
              ++g;
            }
            var yp = y.clone();
            var xp = x.clone();
            while (!x.isZero()) {
              for (
                var i = 0, im = 1;
                (x.words[0] & im) === 0 && i < 26;
                ++i, im <<= 1
              );
              if (i > 0) {
                x.iushrn(i);
                while (i-- > 0) {
                  if (A.isOdd() || B.isOdd()) {
                    A.iadd(yp);
                    B.isub(xp);
                  }
                  A.iushrn(1);
                  B.iushrn(1);
                }
              }
              for (
                var j = 0, jm = 1;
                (y.words[0] & jm) === 0 && j < 26;
                ++j, jm <<= 1
              );
              if (j > 0) {
                y.iushrn(j);
                while (j-- > 0) {
                  if (C.isOdd() || D.isOdd()) {
                    C.iadd(yp);
                    D.isub(xp);
                  }
                  C.iushrn(1);
                  D.iushrn(1);
                }
              }
              if (x.cmp(y) >= 0) {
                x.isub(y);
                A.isub(C);
                B.isub(D);
              } else {
                y.isub(x);
                C.isub(A);
                D.isub(B);
              }
            }
            return { a: C, b: D, gcd: y.iushln(g) };
          };
          BN.prototype._invmp = function _invmp(p) {
            assert(p.negative === 0);
            assert(!p.isZero());
            var a = this;
            var b = p.clone();
            if (a.negative !== 0) {
              a = a.umod(p);
            } else {
              a = a.clone();
            }
            var x1 = new BN(1);
            var x2 = new BN(0);
            var delta = b.clone();
            while (a.cmpn(1) > 0 && b.cmpn(1) > 0) {
              for (
                var i = 0, im = 1;
                (a.words[0] & im) === 0 && i < 26;
                ++i, im <<= 1
              );
              if (i > 0) {
                a.iushrn(i);
                while (i-- > 0) {
                  if (x1.isOdd()) {
                    x1.iadd(delta);
                  }
                  x1.iushrn(1);
                }
              }
              for (
                var j = 0, jm = 1;
                (b.words[0] & jm) === 0 && j < 26;
                ++j, jm <<= 1
              );
              if (j > 0) {
                b.iushrn(j);
                while (j-- > 0) {
                  if (x2.isOdd()) {
                    x2.iadd(delta);
                  }
                  x2.iushrn(1);
                }
              }
              if (a.cmp(b) >= 0) {
                a.isub(b);
                x1.isub(x2);
              } else {
                b.isub(a);
                x2.isub(x1);
              }
            }
            var res;
            if (a.cmpn(1) === 0) {
              res = x1;
            } else {
              res = x2;
            }
            if (res.cmpn(0) < 0) {
              res.iadd(p);
            }
            return res;
          };
          BN.prototype.gcd = function gcd(num) {
            if (this.isZero()) return num.abs();
            if (num.isZero()) return this.abs();
            var a = this.clone();
            var b = num.clone();
            a.negative = 0;
            b.negative = 0;
            for (var shift = 0; a.isEven() && b.isEven(); shift++) {
              a.iushrn(1);
              b.iushrn(1);
            }
            do {
              while (a.isEven()) {
                a.iushrn(1);
              }
              while (b.isEven()) {
                b.iushrn(1);
              }
              var r = a.cmp(b);
              if (r < 0) {
                var t = a;
                a = b;
                b = t;
              } else if (r === 0 || b.cmpn(1) === 0) {
                break;
              }
              a.isub(b);
            } while (true);
            return b.iushln(shift);
          };
          BN.prototype.invm = function invm(num) {
            return this.egcd(num).a.umod(num);
          };
          BN.prototype.isEven = function isEven() {
            return (this.words[0] & 1) === 0;
          };
          BN.prototype.isOdd = function isOdd() {
            return (this.words[0] & 1) === 1;
          };
          BN.prototype.andln = function andln(num) {
            return this.words[0] & num;
          };
          BN.prototype.bincn = function bincn(bit) {
            assert(typeof bit === "number");
            var r = bit % 26;
            var s = (bit - r) / 26;
            var q = 1 << r;
            if (this.length <= s) {
              this._expand(s + 1);
              this.words[s] |= q;
              return this;
            }
            var carry = q;
            for (var i = s; carry !== 0 && i < this.length; i++) {
              var w = this.words[i] | 0;
              w += carry;
              carry = w >>> 26;
              w &= 67108863;
              this.words[i] = w;
            }
            if (carry !== 0) {
              this.words[i] = carry;
              this.length++;
            }
            return this;
          };
          BN.prototype.isZero = function isZero() {
            return this.length === 1 && this.words[0] === 0;
          };
          BN.prototype.cmpn = function cmpn(num) {
            var negative = num < 0;
            if (this.negative !== 0 && !negative) return -1;
            if (this.negative === 0 && negative) return 1;
            this.strip();
            var res;
            if (this.length > 1) {
              res = 1;
            } else {
              if (negative) {
                num = -num;
              }
              assert(num <= 67108863, "Number is too big");
              var w = this.words[0] | 0;
              res = w === num ? 0 : w < num ? -1 : 1;
            }
            if (this.negative !== 0) return -res | 0;
            return res;
          };
          BN.prototype.cmp = function cmp(num) {
            if (this.negative !== 0 && num.negative === 0) return -1;
            if (this.negative === 0 && num.negative !== 0) return 1;
            var res = this.ucmp(num);
            if (this.negative !== 0) return -res | 0;
            return res;
          };
          BN.prototype.ucmp = function ucmp(num) {
            if (this.length > num.length) return 1;
            if (this.length < num.length) return -1;
            var res = 0;
            for (var i = this.length - 1; i >= 0; i--) {
              var a = this.words[i] | 0;
              var b = num.words[i] | 0;
              if (a === b) continue;
              if (a < b) {
                res = -1;
              } else if (a > b) {
                res = 1;
              }
              break;
            }
            return res;
          };
          BN.prototype.gtn = function gtn(num) {
            return this.cmpn(num) === 1;
          };
          BN.prototype.gt = function gt(num) {
            return this.cmp(num) === 1;
          };
          BN.prototype.gten = function gten(num) {
            return this.cmpn(num) >= 0;
          };
          BN.prototype.gte = function gte(num) {
            return this.cmp(num) >= 0;
          };
          BN.prototype.ltn = function ltn(num) {
            return this.cmpn(num) === -1;
          };
          BN.prototype.lt = function lt(num) {
            return this.cmp(num) === -1;
          };
          BN.prototype.lten = function lten(num) {
            return this.cmpn(num) <= 0;
          };
          BN.prototype.lte = function lte(num) {
            return this.cmp(num) <= 0;
          };
          BN.prototype.eqn = function eqn(num) {
            return this.cmpn(num) === 0;
          };
          BN.prototype.eq = function eq(num) {
            return this.cmp(num) === 0;
          };
          BN.red = function red(num) {
            return new Red(num);
          };
          BN.prototype.toRed = function toRed(ctx) {
            assert(!this.red, "Already a number in reduction context");
            assert(this.negative === 0, "red works only with positives");
            return ctx.convertTo(this)._forceRed(ctx);
          };
          BN.prototype.fromRed = function fromRed() {
            assert(
              this.red,
              "fromRed works only with numbers in reduction context"
            );
            return this.red.convertFrom(this);
          };
          BN.prototype._forceRed = function _forceRed(ctx) {
            this.red = ctx;
            return this;
          };
          BN.prototype.forceRed = function forceRed(ctx) {
            assert(!this.red, "Already a number in reduction context");
            return this._forceRed(ctx);
          };
          BN.prototype.redAdd = function redAdd(num) {
            assert(this.red, "redAdd works only with red numbers");
            return this.red.add(this, num);
          };
          BN.prototype.redIAdd = function redIAdd(num) {
            assert(this.red, "redIAdd works only with red numbers");
            return this.red.iadd(this, num);
          };
          BN.prototype.redSub = function redSub(num) {
            assert(this.red, "redSub works only with red numbers");
            return this.red.sub(this, num);
          };
          BN.prototype.redISub = function redISub(num) {
            assert(this.red, "redISub works only with red numbers");
            return this.red.isub(this, num);
          };
          BN.prototype.redShl = function redShl(num) {
            assert(this.red, "redShl works only with red numbers");
            return this.red.shl(this, num);
          };
          BN.prototype.redMul = function redMul(num) {
            assert(this.red, "redMul works only with red numbers");
            this.red._verify2(this, num);
            return this.red.mul(this, num);
          };
          BN.prototype.redIMul = function redIMul(num) {
            assert(this.red, "redMul works only with red numbers");
            this.red._verify2(this, num);
            return this.red.imul(this, num);
          };
          BN.prototype.redSqr = function redSqr() {
            assert(this.red, "redSqr works only with red numbers");
            this.red._verify1(this);
            return this.red.sqr(this);
          };
          BN.prototype.redISqr = function redISqr() {
            assert(this.red, "redISqr works only with red numbers");
            this.red._verify1(this);
            return this.red.isqr(this);
          };
          BN.prototype.redSqrt = function redSqrt() {
            assert(this.red, "redSqrt works only with red numbers");
            this.red._verify1(this);
            return this.red.sqrt(this);
          };
          BN.prototype.redInvm = function redInvm() {
            assert(this.red, "redInvm works only with red numbers");
            this.red._verify1(this);
            return this.red.invm(this);
          };
          BN.prototype.redNeg = function redNeg() {
            assert(this.red, "redNeg works only with red numbers");
            this.red._verify1(this);
            return this.red.neg(this);
          };
          BN.prototype.redPow = function redPow(num) {
            assert(this.red && !num.red, "redPow(normalNum)");
            this.red._verify1(this);
            return this.red.pow(this, num);
          };
          var primes = { k256: null, p224: null, p192: null, p25519: null };
          function MPrime(name, p) {
            this.name = name;
            this.p = new BN(p, 16);
            this.n = this.p.bitLength();
            this.k = new BN(1).iushln(this.n).isub(this.p);
            this.tmp = this._tmp();
          }
          MPrime.prototype._tmp = function _tmp() {
            var tmp = new BN(null);
            tmp.words = new Array(Math.ceil(this.n / 13));
            return tmp;
          };
          MPrime.prototype.ireduce = function ireduce(num) {
            var r = num;
            var rlen;
            do {
              this.split(r, this.tmp);
              r = this.imulK(r);
              r = r.iadd(this.tmp);
              rlen = r.bitLength();
            } while (rlen > this.n);
            var cmp = rlen < this.n ? -1 : r.ucmp(this.p);
            if (cmp === 0) {
              r.words[0] = 0;
              r.length = 1;
            } else if (cmp > 0) {
              r.isub(this.p);
            } else {
              if (r.strip !== undefined) {
                r.strip();
              } else {
                r._strip();
              }
            }
            return r;
          };
          MPrime.prototype.split = function split(input, out) {
            input.iushrn(this.n, 0, out);
          };
          MPrime.prototype.imulK = function imulK(num) {
            return num.imul(this.k);
          };
          function K256() {
            MPrime.call(
              this,
              "k256",
              "ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff fffffffe fffffc2f"
            );
          }
          inherits(K256, MPrime);
          K256.prototype.split = function split(input, output) {
            var mask = 4194303;
            var outLen = Math.min(input.length, 9);
            for (var i = 0; i < outLen; i++) {
              output.words[i] = input.words[i];
            }
            output.length = outLen;
            if (input.length <= 9) {
              input.words[0] = 0;
              input.length = 1;
              return;
            }
            var prev = input.words[9];
            output.words[output.length++] = prev & mask;
            for (i = 10; i < input.length; i++) {
              var next = input.words[i] | 0;
              input.words[i - 10] = ((next & mask) << 4) | (prev >>> 22);
              prev = next;
            }
            prev >>>= 22;
            input.words[i - 10] = prev;
            if (prev === 0 && input.length > 10) {
              input.length -= 10;
            } else {
              input.length -= 9;
            }
          };
          K256.prototype.imulK = function imulK(num) {
            num.words[num.length] = 0;
            num.words[num.length + 1] = 0;
            num.length += 2;
            var lo = 0;
            for (var i = 0; i < num.length; i++) {
              var w = num.words[i] | 0;
              lo += w * 977;
              num.words[i] = lo & 67108863;
              lo = w * 64 + ((lo / 67108864) | 0);
            }
            if (num.words[num.length - 1] === 0) {
              num.length--;
              if (num.words[num.length - 1] === 0) {
                num.length--;
              }
            }
            return num;
          };
          function P224() {
            MPrime.call(
              this,
              "p224",
              "ffffffff ffffffff ffffffff ffffffff 00000000 00000000 00000001"
            );
          }
          inherits(P224, MPrime);
          function P192() {
            MPrime.call(
              this,
              "p192",
              "ffffffff ffffffff ffffffff fffffffe ffffffff ffffffff"
            );
          }
          inherits(P192, MPrime);
          function P25519() {
            MPrime.call(
              this,
              "25519",
              "7fffffffffffffff ffffffffffffffff ffffffffffffffff ffffffffffffffed"
            );
          }
          inherits(P25519, MPrime);
          P25519.prototype.imulK = function imulK(num) {
            var carry = 0;
            for (var i = 0; i < num.length; i++) {
              var hi = (num.words[i] | 0) * 19 + carry;
              var lo = hi & 67108863;
              hi >>>= 26;
              num.words[i] = lo;
              carry = hi;
            }
            if (carry !== 0) {
              num.words[num.length++] = carry;
            }
            return num;
          };
          BN._prime = function prime(name) {
            if (primes[name]) return primes[name];
            var prime;
            if (name === "k256") {
              prime = new K256();
            } else if (name === "p224") {
              prime = new P224();
            } else if (name === "p192") {
              prime = new P192();
            } else if (name === "p25519") {
              prime = new P25519();
            } else {
              throw new Error("Unknown prime " + name);
            }
            primes[name] = prime;
            return prime;
          };
          function Red(m) {
            if (typeof m === "string") {
              var prime = BN._prime(m);
              this.m = prime.p;
              this.prime = prime;
            } else {
              assert(m.gtn(1), "modulus must be greater than 1");
              this.m = m;
              this.prime = null;
            }
          }
          Red.prototype._verify1 = function _verify1(a) {
            assert(a.negative === 0, "red works only with positives");
            assert(a.red, "red works only with red numbers");
          };
          Red.prototype._verify2 = function _verify2(a, b) {
            assert(
              (a.negative | b.negative) === 0,
              "red works only with positives"
            );
            assert(a.red && a.red === b.red, "red works only with red numbers");
          };
          Red.prototype.imod = function imod(a) {
            if (this.prime) return this.prime.ireduce(a)._forceRed(this);
            return a.umod(this.m)._forceRed(this);
          };
          Red.prototype.neg = function neg(a) {
            if (a.isZero()) {
              return a.clone();
            }
            return this.m.sub(a)._forceRed(this);
          };
          Red.prototype.add = function add(a, b) {
            this._verify2(a, b);
            var res = a.add(b);
            if (res.cmp(this.m) >= 0) {
              res.isub(this.m);
            }
            return res._forceRed(this);
          };
          Red.prototype.iadd = function iadd(a, b) {
            this._verify2(a, b);
            var res = a.iadd(b);
            if (res.cmp(this.m) >= 0) {
              res.isub(this.m);
            }
            return res;
          };
          Red.prototype.sub = function sub(a, b) {
            this._verify2(a, b);
            var res = a.sub(b);
            if (res.cmpn(0) < 0) {
              res.iadd(this.m);
            }
            return res._forceRed(this);
          };
          Red.prototype.isub = function isub(a, b) {
            this._verify2(a, b);
            var res = a.isub(b);
            if (res.cmpn(0) < 0) {
              res.iadd(this.m);
            }
            return res;
          };
          Red.prototype.shl = function shl(a, num) {
            this._verify1(a);
            return this.imod(a.ushln(num));
          };
          Red.prototype.imul = function imul(a, b) {
            this._verify2(a, b);
            return this.imod(a.imul(b));
          };
          Red.prototype.mul = function mul(a, b) {
            this._verify2(a, b);
            return this.imod(a.mul(b));
          };
          Red.prototype.isqr = function isqr(a) {
            return this.imul(a, a.clone());
          };
          Red.prototype.sqr = function sqr(a) {
            return this.mul(a, a);
          };
          Red.prototype.sqrt = function sqrt(a) {
            if (a.isZero()) return a.clone();
            var mod3 = this.m.andln(3);
            assert(mod3 % 2 === 1);
            if (mod3 === 3) {
              var pow = this.m.add(new BN(1)).iushrn(2);
              return this.pow(a, pow);
            }
            var q = this.m.subn(1);
            var s = 0;
            while (!q.isZero() && q.andln(1) === 0) {
              s++;
              q.iushrn(1);
            }
            assert(!q.isZero());
            var one = new BN(1).toRed(this);
            var nOne = one.redNeg();
            var lpow = this.m.subn(1).iushrn(1);
            var z = this.m.bitLength();
            z = new BN(2 * z * z).toRed(this);
            while (this.pow(z, lpow).cmp(nOne) !== 0) {
              z.redIAdd(nOne);
            }
            var c = this.pow(z, q);
            var r = this.pow(a, q.addn(1).iushrn(1));
            var t = this.pow(a, q);
            var m = s;
            while (t.cmp(one) !== 0) {
              var tmp = t;
              for (var i = 0; tmp.cmp(one) !== 0; i++) {
                tmp = tmp.redSqr();
              }
              assert(i < m);
              var b = this.pow(c, new BN(1).iushln(m - i - 1));
              r = r.redMul(b);
              c = b.redSqr();
              t = t.redMul(c);
              m = i;
            }
            return r;
          };
          Red.prototype.invm = function invm(a) {
            var inv = a._invmp(this.m);
            if (inv.negative !== 0) {
              inv.negative = 0;
              return this.imod(inv).redNeg();
            } else {
              return this.imod(inv);
            }
          };
          Red.prototype.pow = function pow(a, num) {
            if (num.isZero()) return new BN(1).toRed(this);
            if (num.cmpn(1) === 0) return a.clone();
            var windowSize = 4;
            var wnd = new Array(1 << windowSize);
            wnd[0] = new BN(1).toRed(this);
            wnd[1] = a;
            for (var i = 2; i < wnd.length; i++) {
              wnd[i] = this.mul(wnd[i - 1], a);
            }
            var res = wnd[0];
            var current = 0;
            var currentLen = 0;
            var start = num.bitLength() % 26;
            if (start === 0) {
              start = 26;
            }
            for (i = num.length - 1; i >= 0; i--) {
              var word = num.words[i];
              for (var j = start - 1; j >= 0; j--) {
                var bit = (word >> j) & 1;
                if (res !== wnd[0]) {
                  res = this.sqr(res);
                }
                if (bit === 0 && current === 0) {
                  currentLen = 0;
                  continue;
                }
                current <<= 1;
                current |= bit;
                currentLen++;
                if (currentLen !== windowSize && (i !== 0 || j !== 0)) continue;
                res = this.mul(res, wnd[current]);
                currentLen = 0;
                current = 0;
              }
              start = 26;
            }
            return res;
          };
          Red.prototype.convertTo = function convertTo(num) {
            var r = num.umod(this.m);
            return r === num ? r.clone() : r;
          };
          Red.prototype.convertFrom = function convertFrom(num) {
            var res = num.clone();
            res.red = null;
            return res;
          };
          BN.mont = function mont(num) {
            return new Mont(num);
          };
          function Mont(m) {
            Red.call(this, m);
            this.shift = this.m.bitLength();
            if (this.shift % 26 !== 0) {
              this.shift += 26 - (this.shift % 26);
            }
            this.r = new BN(1).iushln(this.shift);
            this.r2 = this.imod(this.r.sqr());
            this.rinv = this.r._invmp(this.m);
            this.minv = this.rinv.mul(this.r).isubn(1).div(this.m);
            this.minv = this.minv.umod(this.r);
            this.minv = this.r.sub(this.minv);
          }
          inherits(Mont, Red);
          Mont.prototype.convertTo = function convertTo(num) {
            return this.imod(num.ushln(this.shift));
          };
          Mont.prototype.convertFrom = function convertFrom(num) {
            var r = this.imod(num.mul(this.rinv));
            r.red = null;
            return r;
          };
          Mont.prototype.imul = function imul(a, b) {
            if (a.isZero() || b.isZero()) {
              a.words[0] = 0;
              a.length = 1;
              return a;
            }
            var t = a.imul(b);
            var c = t
              .maskn(this.shift)
              .mul(this.minv)
              .imaskn(this.shift)
              .mul(this.m);
            var u = t.isub(c).iushrn(this.shift);
            var res = u;
            if (u.cmp(this.m) >= 0) {
              res = u.isub(this.m);
            } else if (u.cmpn(0) < 0) {
              res = u.iadd(this.m);
            }
            return res._forceRed(this);
          };
          Mont.prototype.mul = function mul(a, b) {
            if (a.isZero() || b.isZero()) return new BN(0)._forceRed(this);
            var t = a.mul(b);
            var c = t
              .maskn(this.shift)
              .mul(this.minv)
              .imaskn(this.shift)
              .mul(this.m);
            var u = t.isub(c).iushrn(this.shift);
            var res = u;
            if (u.cmp(this.m) >= 0) {
              res = u.isub(this.m);
            } else if (u.cmpn(0) < 0) {
              res = u.iadd(this.m);
            }
            return res._forceRed(this);
          };
          Mont.prototype.invm = function invm(a) {
            var res = this.imod(a._invmp(this.m).mul(this.r2));
            return res._forceRed(this);
          };
        })(typeof module === "undefined" || module, this);
      },
      { buffer: 24 },
    ],
    7: [
      function (require, module, exports) {
        (function (Buffer) {
          (function () {
            "use strict";
            Object.defineProperty(exports, "__esModule", { value: true });
            exports.importPublic =
              exports.privateToPublic =
              exports.privateToAddress =
              exports.publicToAddress =
              exports.pubToAddress =
              exports.isValidPublic =
              exports.isValidPrivate =
              exports.isPrecompiled =
              exports.generateAddress2 =
              exports.generateAddress =
              exports.isValidChecksumAddress =
              exports.toChecksumAddress =
              exports.isZeroAddress =
              exports.isValidAddress =
              exports.zeroAddress =
                void 0;
            var assert = require("assert");
            var ethjsUtil = require("ethjs-util");
            var secp256k1 = require("./secp256k1v3-adapter");
            var BN = require("bn.js");
            var bytes_1 = require("./bytes");
            var hash_1 = require("./hash");
            exports.zeroAddress = function () {
              var addressLength = 20;
              var addr = bytes_1.zeros(addressLength);
              return bytes_1.bufferToHex(addr);
            };
            exports.isValidAddress = function (address) {
              return /^0x[0-9a-fA-F]{40}$/.test(address);
            };
            exports.isZeroAddress = function (address) {
              var zeroAddr = exports.zeroAddress();
              return zeroAddr === bytes_1.addHexPrefix(address);
            };
            exports.toChecksumAddress = function (address, eip1191ChainId) {
              address = ethjsUtil.stripHexPrefix(address).toLowerCase();
              var prefix =
                eip1191ChainId !== undefined
                  ? eip1191ChainId.toString() + "0x"
                  : "";
              var hash = hash_1.keccak(prefix + address).toString("hex");
              var ret = "0x";
              for (var i = 0; i < address.length; i++) {
                if (parseInt(hash[i], 16) >= 8) {
                  ret += address[i].toUpperCase();
                } else {
                  ret += address[i];
                }
              }
              return ret;
            };
            exports.isValidChecksumAddress = function (
              address,
              eip1191ChainId
            ) {
              return (
                exports.isValidAddress(address) &&
                exports.toChecksumAddress(address, eip1191ChainId) === address
              );
            };
            exports.generateAddress = function (from, nonce) {
              from = bytes_1.toBuffer(from);
              var nonceBN = new BN(nonce);
              if (nonceBN.isZero()) {
                return hash_1.rlphash([from, null]).slice(-20);
              }
              return hash_1
                .rlphash([from, Buffer.from(nonceBN.toArray())])
                .slice(-20);
            };
            exports.generateAddress2 = function (from, salt, initCode) {
              var fromBuf = bytes_1.toBuffer(from);
              var saltBuf = bytes_1.toBuffer(salt);
              var initCodeBuf = bytes_1.toBuffer(initCode);
              assert(fromBuf.length === 20);
              assert(saltBuf.length === 32);
              var address = hash_1.keccak256(
                Buffer.concat([
                  Buffer.from("ff", "hex"),
                  fromBuf,
                  saltBuf,
                  hash_1.keccak256(initCodeBuf),
                ])
              );
              return address.slice(-20);
            };
            exports.isPrecompiled = function (address) {
              var a = bytes_1.unpad(address);
              return a.length === 1 && a[0] >= 1 && a[0] <= 8;
            };
            exports.isValidPrivate = function (privateKey) {
              return secp256k1.privateKeyVerify(privateKey);
            };
            exports.isValidPublic = function (publicKey, sanitize) {
              if (sanitize === void 0) {
                sanitize = false;
              }
              if (publicKey.length === 64) {
                return secp256k1.publicKeyVerify(
                  Buffer.concat([Buffer.from([4]), publicKey])
                );
              }
              if (!sanitize) {
                return false;
              }
              return secp256k1.publicKeyVerify(publicKey);
            };
            exports.pubToAddress = function (pubKey, sanitize) {
              if (sanitize === void 0) {
                sanitize = false;
              }
              pubKey = bytes_1.toBuffer(pubKey);
              if (sanitize && pubKey.length !== 64) {
                pubKey = secp256k1.publicKeyConvert(pubKey, false).slice(1);
              }
              assert(pubKey.length === 64);
              return hash_1.keccak(pubKey).slice(-20);
            };
            exports.publicToAddress = exports.pubToAddress;
            exports.privateToAddress = function (privateKey) {
              return exports.publicToAddress(
                exports.privateToPublic(privateKey)
              );
            };
            exports.privateToPublic = function (privateKey) {
              privateKey = bytes_1.toBuffer(privateKey);
              return secp256k1.publicKeyCreate(privateKey, false).slice(1);
            };
            exports.importPublic = function (publicKey) {
              publicKey = bytes_1.toBuffer(publicKey);
              if (publicKey.length !== 64) {
                publicKey = secp256k1
                  .publicKeyConvert(publicKey, false)
                  .slice(1);
              }
              return publicKey;
            };
          }).call(this);
        }).call(this, require("buffer").Buffer);
      },
      {
        "./bytes": 8,
        "./hash": 10,
        "./secp256k1v3-adapter": 13,
        assert: 17,
        "bn.js": 6,
        buffer: 25,
        "ethjs-util": 62,
      },
    ],
    8: [
      function (require, module, exports) {
        (function (Buffer) {
          (function () {
            "use strict";
            Object.defineProperty(exports, "__esModule", { value: true });
            exports.baToJSON =
              exports.addHexPrefix =
              exports.toUnsigned =
              exports.fromSigned =
              exports.bufferToHex =
              exports.bufferToInt =
              exports.toBuffer =
              exports.stripZeros =
              exports.unpad =
              exports.setLengthRight =
              exports.setLength =
              exports.setLengthLeft =
              exports.zeros =
                void 0;
            var ethjsUtil = require("ethjs-util");
            var BN = require("bn.js");
            exports.zeros = function (bytes) {
              return Buffer.allocUnsafe(bytes).fill(0);
            };
            exports.setLengthLeft = function (msg, length, right) {
              if (right === void 0) {
                right = false;
              }
              var buf = exports.zeros(length);
              msg = exports.toBuffer(msg);
              if (right) {
                if (msg.length < length) {
                  msg.copy(buf);
                  return buf;
                }
                return msg.slice(0, length);
              } else {
                if (msg.length < length) {
                  msg.copy(buf, length - msg.length);
                  return buf;
                }
                return msg.slice(-length);
              }
            };
            exports.setLength = exports.setLengthLeft;
            exports.setLengthRight = function (msg, length) {
              return exports.setLength(msg, length, true);
            };
            exports.unpad = function (a) {
              a = ethjsUtil.stripHexPrefix(a);
              var first = a[0];
              while (a.length > 0 && first.toString() === "0") {
                a = a.slice(1);
                first = a[0];
              }
              return a;
            };
            exports.stripZeros = exports.unpad;
            exports.toBuffer = function (v) {
              if (!Buffer.isBuffer(v)) {
                if (Array.isArray(v)) {
                  v = Buffer.from(v);
                } else if (typeof v === "string") {
                  if (ethjsUtil.isHexString(v)) {
                    v = Buffer.from(
                      ethjsUtil.padToEven(ethjsUtil.stripHexPrefix(v)),
                      "hex"
                    );
                  } else {
                    throw new Error(
                      "Cannot convert string to buffer. toBuffer only supports 0x-prefixed hex strings and this string was given: " +
                        v
                    );
                  }
                } else if (typeof v === "number") {
                  v = ethjsUtil.intToBuffer(v);
                } else if (v === null || v === undefined) {
                  v = Buffer.allocUnsafe(0);
                } else if (BN.isBN(v)) {
                  v = v.toArrayLike(Buffer);
                } else if (v.toArray) {
                  v = Buffer.from(v.toArray());
                } else {
                  throw new Error("invalid type");
                }
              }
              return v;
            };
            exports.bufferToInt = function (buf) {
              return new BN(exports.toBuffer(buf)).toNumber();
            };
            exports.bufferToHex = function (buf) {
              buf = exports.toBuffer(buf);
              return "0x" + buf.toString("hex");
            };
            exports.fromSigned = function (num) {
              return new BN(num).fromTwos(256);
            };
            exports.toUnsigned = function (num) {
              return Buffer.from(num.toTwos(256).toArray());
            };
            exports.addHexPrefix = function (str) {
              if (typeof str !== "string") {
                return str;
              }
              return ethjsUtil.isHexPrefixed(str) ? str : "0x" + str;
            };
            exports.baToJSON = function (ba) {
              if (Buffer.isBuffer(ba)) {
                return "0x" + ba.toString("hex");
              } else if (ba instanceof Array) {
                var array = [];
                for (var i = 0; i < ba.length; i++) {
                  array.push(exports.baToJSON(ba[i]));
                }
                return array;
              }
            };
          }).call(this);
        }).call(this, require("buffer").Buffer);
      },
      { "bn.js": 6, buffer: 25, "ethjs-util": 62 },
    ],
    9: [
      function (require, module, exports) {
        (function (Buffer) {
          (function () {
            "use strict";
            Object.defineProperty(exports, "__esModule", { value: true });
            exports.KECCAK256_RLP =
              exports.KECCAK256_RLP_S =
              exports.KECCAK256_RLP_ARRAY =
              exports.KECCAK256_RLP_ARRAY_S =
              exports.KECCAK256_NULL =
              exports.KECCAK256_NULL_S =
              exports.TWO_POW256 =
              exports.MAX_INTEGER =
                void 0;
            var BN = require("bn.js");
            exports.MAX_INTEGER = new BN(
              "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
              16
            );
            exports.TWO_POW256 = new BN(
              "10000000000000000000000000000000000000000000000000000000000000000",
              16
            );
            exports.KECCAK256_NULL_S =
              "c5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470";
            exports.KECCAK256_NULL = Buffer.from(
              exports.KECCAK256_NULL_S,
              "hex"
            );
            exports.KECCAK256_RLP_ARRAY_S =
              "1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347";
            exports.KECCAK256_RLP_ARRAY = Buffer.from(
              exports.KECCAK256_RLP_ARRAY_S,
              "hex"
            );
            exports.KECCAK256_RLP_S =
              "56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421";
            exports.KECCAK256_RLP = Buffer.from(exports.KECCAK256_RLP_S, "hex");
          }).call(this);
        }).call(this, require("buffer").Buffer);
      },
      { "bn.js": 6, buffer: 25 },
    ],
    10: [
      function (require, module, exports) {
        (function (Buffer) {
          (function () {
            "use strict";
            Object.defineProperty(exports, "__esModule", { value: true });
            exports.rlphash =
              exports.ripemd160 =
              exports.sha256 =
              exports.keccak256 =
              exports.keccak =
                void 0;
            var _a = require("ethereum-cryptography/keccak"),
              keccak224 = _a.keccak224,
              keccak384 = _a.keccak384,
              k256 = _a.keccak256,
              keccak512 = _a.keccak512;
            var createHash = require("create-hash");
            var ethjsUtil = require("ethjs-util");
            var rlp = require("rlp");
            var bytes_1 = require("./bytes");
            exports.keccak = function (a, bits) {
              if (bits === void 0) {
                bits = 256;
              }
              if (typeof a === "string" && !ethjsUtil.isHexString(a)) {
                a = Buffer.from(a, "utf8");
              } else {
                a = bytes_1.toBuffer(a);
              }
              if (!bits) bits = 256;
              switch (bits) {
                case 224: {
                  return keccak224(a);
                }
                case 256: {
                  return k256(a);
                }
                case 384: {
                  return keccak384(a);
                }
                case 512: {
                  return keccak512(a);
                }
                default: {
                  throw new Error("Invald algorithm: keccak" + bits);
                }
              }
            };
            exports.keccak256 = function (a) {
              return exports.keccak(a);
            };
            exports.sha256 = function (a) {
              a = bytes_1.toBuffer(a);
              return createHash("sha256").update(a).digest();
            };
            exports.ripemd160 = function (a, padded) {
              a = bytes_1.toBuffer(a);
              var hash = createHash("rmd160").update(a).digest();
              if (padded === true) {
                return bytes_1.setLength(hash, 32);
              } else {
                return hash;
              }
            };
            exports.rlphash = function (a) {
              return exports.keccak(rlp.encode(a));
            };
          }).call(this);
        }).call(this, require("buffer").Buffer);
      },
      {
        "./bytes": 8,
        buffer: 25,
        "create-hash": 27,
        "ethereum-cryptography/keccak": 46,
        "ethjs-util": 62,
        rlp: 125,
      },
    ],
    11: [
      function (require, module, exports) {
        "use strict";
        var __createBinding =
          (this && this.__createBinding) ||
          (Object.create
            ? function (o, m, k, k2) {
                if (k2 === undefined) k2 = k;
                Object.defineProperty(o, k2, {
                  enumerable: true,
                  get: function () {
                    return m[k];
                  },
                });
              }
            : function (o, m, k, k2) {
                if (k2 === undefined) k2 = k;
                o[k2] = m[k];
              });
        var __exportStar =
          (this && this.__exportStar) ||
          function (m, exports) {
            for (var p in m)
              if (p !== "default" && !exports.hasOwnProperty(p))
                __createBinding(exports, m, p);
          };
        Object.defineProperty(exports, "__esModule", { value: true });
        exports.secp256k1 = exports.rlp = exports.BN = void 0;
        var secp256k1 = require("./secp256k1v3-adapter");
        exports.secp256k1 = secp256k1;
        var ethjsUtil = require("ethjs-util");
        var BN = require("bn.js");
        exports.BN = BN;
        var rlp = require("rlp");
        exports.rlp = rlp;
        Object.assign(exports, ethjsUtil);
        __exportStar(require("./constants"), exports);
        __exportStar(require("./account"), exports);
        __exportStar(require("./hash"), exports);
        __exportStar(require("./signature"), exports);
        __exportStar(require("./bytes"), exports);
        __exportStar(require("./object"), exports);
      },
      {
        "./account": 7,
        "./bytes": 8,
        "./constants": 9,
        "./hash": 10,
        "./object": 12,
        "./secp256k1v3-adapter": 13,
        "./signature": 16,
        "bn.js": 6,
        "ethjs-util": 62,
        rlp: 125,
      },
    ],
    12: [
      function (require, module, exports) {
        (function (Buffer) {
          (function () {
            "use strict";
            Object.defineProperty(exports, "__esModule", { value: true });
            exports.defineProperties = void 0;
            var assert = require("assert");
            var ethjsUtil = require("ethjs-util");
            var rlp = require("rlp");
            var bytes_1 = require("./bytes");
            exports.defineProperties = function (self, fields, data) {
              self.raw = [];
              self._fields = [];
              self.toJSON = function (label) {
                if (label === void 0) {
                  label = false;
                }
                if (label) {
                  var obj_1 = {};
                  self._fields.forEach(function (field) {
                    obj_1[field] = "0x" + self[field].toString("hex");
                  });
                  return obj_1;
                }
                return bytes_1.baToJSON(self.raw);
              };
              self.serialize = function serialize() {
                return rlp.encode(self.raw);
              };
              fields.forEach(function (field, i) {
                self._fields.push(field.name);
                function getter() {
                  return self.raw[i];
                }
                function setter(v) {
                  v = bytes_1.toBuffer(v);
                  if (v.toString("hex") === "00" && !field.allowZero) {
                    v = Buffer.allocUnsafe(0);
                  }
                  if (field.allowLess && field.length) {
                    v = bytes_1.stripZeros(v);
                    assert(
                      field.length >= v.length,
                      "The field " +
                        field.name +
                        " must not have more " +
                        field.length +
                        " bytes"
                    );
                  } else if (
                    !(field.allowZero && v.length === 0) &&
                    field.length
                  ) {
                    assert(
                      field.length === v.length,
                      "The field " +
                        field.name +
                        " must have byte length of " +
                        field.length
                    );
                  }
                  self.raw[i] = v;
                }
                Object.defineProperty(self, field.name, {
                  enumerable: true,
                  configurable: true,
                  get: getter,
                  set: setter,
                });
                if (field.default) {
                  self[field.name] = field.default;
                }
                if (field.alias) {
                  Object.defineProperty(self, field.alias, {
                    enumerable: false,
                    configurable: true,
                    set: setter,
                    get: getter,
                  });
                }
              });
              if (data) {
                if (typeof data === "string") {
                  data = Buffer.from(ethjsUtil.stripHexPrefix(data), "hex");
                }
                if (Buffer.isBuffer(data)) {
                  data = rlp.decode(data);
                }
                if (Array.isArray(data)) {
                  if (data.length > self._fields.length) {
                    throw new Error("wrong number of fields in data");
                  }
                  data.forEach(function (d, i) {
                    self[self._fields[i]] = bytes_1.toBuffer(d);
                  });
                } else if (typeof data === "object") {
                  var keys_1 = Object.keys(data);
                  fields.forEach(function (field) {
                    if (keys_1.indexOf(field.name) !== -1)
                      self[field.name] = data[field.name];
                    if (keys_1.indexOf(field.alias) !== -1)
                      self[field.alias] = data[field.alias];
                  });
                } else {
                  throw new Error("invalid data");
                }
              }
            };
          }).call(this);
        }).call(this, require("buffer").Buffer);
      },
      { "./bytes": 8, assert: 17, buffer: 25, "ethjs-util": 62, rlp: 125 },
    ],
    13: [
      function (require, module, exports) {
        (function (Buffer) {
          (function () {
            "use strict";
            Object.defineProperty(exports, "__esModule", { value: true });
            exports.ecdhUnsafe =
              exports.ecdh =
              exports.recover =
              exports.verify =
              exports.sign =
              exports.signatureImportLax =
              exports.signatureImport =
              exports.signatureExport =
              exports.signatureNormalize =
              exports.publicKeyCombine =
              exports.publicKeyTweakMul =
              exports.publicKeyTweakAdd =
              exports.publicKeyVerify =
              exports.publicKeyConvert =
              exports.publicKeyCreate =
              exports.privateKeyTweakMul =
              exports.privateKeyTweakAdd =
              exports.privateKeyModInverse =
              exports.privateKeyNegate =
              exports.privateKeyImport =
              exports.privateKeyExport =
              exports.privateKeyVerify =
                void 0;
            var secp256k1 = require("ethereum-cryptography/secp256k1");
            var secp256k1v3 = require("./secp256k1v3-lib/index");
            var der = require("./secp256k1v3-lib/der");
            exports.privateKeyVerify = function (privateKey) {
              if (privateKey.length !== 32) {
                return false;
              }
              return secp256k1.privateKeyVerify(Uint8Array.from(privateKey));
            };
            exports.privateKeyExport = function (privateKey, compressed) {
              if (privateKey.length !== 32) {
                throw new RangeError("private key length is invalid");
              }
              var publicKey = secp256k1v3.privateKeyExport(
                privateKey,
                compressed
              );
              return der.privateKeyExport(privateKey, publicKey, compressed);
            };
            exports.privateKeyImport = function (privateKey) {
              privateKey = der.privateKeyImport(privateKey);
              if (
                privateKey !== null &&
                privateKey.length === 32 &&
                exports.privateKeyVerify(privateKey)
              ) {
                return privateKey;
              }
              throw new Error("couldn't import from DER format");
            };
            exports.privateKeyNegate = function (privateKey) {
              return Buffer.from(
                secp256k1.privateKeyNegate(Uint8Array.from(privateKey))
              );
            };
            exports.privateKeyModInverse = function (privateKey) {
              if (privateKey.length !== 32) {
                throw new Error("private key length is invalid");
              }
              return Buffer.from(
                secp256k1v3.privateKeyModInverse(Uint8Array.from(privateKey))
              );
            };
            exports.privateKeyTweakAdd = function (privateKey, tweak) {
              return Buffer.from(
                secp256k1.privateKeyTweakAdd(Uint8Array.from(privateKey), tweak)
              );
            };
            exports.privateKeyTweakMul = function (privateKey, tweak) {
              return Buffer.from(
                secp256k1.privateKeyTweakMul(
                  Uint8Array.from(privateKey),
                  Uint8Array.from(tweak)
                )
              );
            };
            exports.publicKeyCreate = function (privateKey, compressed) {
              return Buffer.from(
                secp256k1.publicKeyCreate(
                  Uint8Array.from(privateKey),
                  compressed
                )
              );
            };
            exports.publicKeyConvert = function (publicKey, compressed) {
              return Buffer.from(
                secp256k1.publicKeyConvert(
                  Uint8Array.from(publicKey),
                  compressed
                )
              );
            };
            exports.publicKeyVerify = function (publicKey) {
              if (publicKey.length !== 33 && publicKey.length !== 65) {
                return false;
              }
              return secp256k1.publicKeyVerify(Uint8Array.from(publicKey));
            };
            exports.publicKeyTweakAdd = function (
              publicKey,
              tweak,
              compressed
            ) {
              return Buffer.from(
                secp256k1.publicKeyTweakAdd(
                  Uint8Array.from(publicKey),
                  Uint8Array.from(tweak),
                  compressed
                )
              );
            };
            exports.publicKeyTweakMul = function (
              publicKey,
              tweak,
              compressed
            ) {
              return Buffer.from(
                secp256k1.publicKeyTweakMul(
                  Uint8Array.from(publicKey),
                  Uint8Array.from(tweak),
                  compressed
                )
              );
            };
            exports.publicKeyCombine = function (publicKeys, compressed) {
              var keys = [];
              publicKeys.forEach(function (publicKey) {
                keys.push(Uint8Array.from(publicKey));
              });
              return Buffer.from(secp256k1.publicKeyCombine(keys, compressed));
            };
            exports.signatureNormalize = function (signature) {
              return Buffer.from(
                secp256k1.signatureNormalize(Uint8Array.from(signature))
              );
            };
            exports.signatureExport = function (signature) {
              return Buffer.from(
                secp256k1.signatureExport(Uint8Array.from(signature))
              );
            };
            exports.signatureImport = function (signature) {
              return Buffer.from(
                secp256k1.signatureImport(Uint8Array.from(signature))
              );
            };
            exports.signatureImportLax = function (signature) {
              if (signature.length === 0) {
                throw new RangeError("signature length is invalid");
              }
              var sigObj = der.signatureImportLax(signature);
              if (sigObj === null) {
                throw new Error("couldn't parse DER signature");
              }
              return secp256k1v3.signatureImport(sigObj);
            };
            exports.sign = function (message, privateKey, options) {
              if (options === null) {
                throw new TypeError("options should be an Object");
              }
              var signOptions = undefined;
              if (options) {
                signOptions = {};
                if (options.data === null) {
                  throw new TypeError("options.data should be a Buffer");
                }
                if (options.data) {
                  if (options.data.length != 32) {
                    throw new RangeError("options.data length is invalid");
                  }
                  signOptions.data = new Uint8Array(options.data);
                }
                if (options.noncefn === null) {
                  throw new TypeError("options.noncefn should be a Function");
                }
                if (options.noncefn) {
                  signOptions.noncefn = function (
                    message,
                    privateKey,
                    algo,
                    data,
                    attempt
                  ) {
                    var bufferAlgo = algo != null ? Buffer.from(algo) : null;
                    var bufferData = data != null ? Buffer.from(data) : null;
                    var buffer = Buffer.from("");
                    if (options.noncefn) {
                      buffer = options.noncefn(
                        Buffer.from(message),
                        Buffer.from(privateKey),
                        bufferAlgo,
                        bufferData,
                        attempt
                      );
                    }
                    return new Uint8Array(buffer);
                  };
                }
              }
              var sig = secp256k1.ecdsaSign(
                Uint8Array.from(message),
                Uint8Array.from(privateKey),
                signOptions
              );
              return {
                signature: Buffer.from(sig.signature),
                recovery: sig.recid,
              };
            };
            exports.verify = function (message, signature, publicKey) {
              return secp256k1.ecdsaVerify(
                Uint8Array.from(signature),
                Uint8Array.from(message),
                publicKey
              );
            };
            exports.recover = function (message, signature, recid, compressed) {
              return Buffer.from(
                secp256k1.ecdsaRecover(
                  Uint8Array.from(signature),
                  recid,
                  Uint8Array.from(message),
                  compressed
                )
              );
            };
            exports.ecdh = function (publicKey, privateKey) {
              return Buffer.from(
                secp256k1.ecdh(
                  Uint8Array.from(publicKey),
                  Uint8Array.from(privateKey),
                  {}
                )
              );
            };
            exports.ecdhUnsafe = function (publicKey, privateKey, compressed) {
              if (publicKey.length !== 33 && publicKey.length !== 65) {
                throw new RangeError("public key length is invalid");
              }
              if (privateKey.length !== 32) {
                throw new RangeError("private key length is invalid");
              }
              return Buffer.from(
                secp256k1v3.ecdhUnsafe(
                  Uint8Array.from(publicKey),
                  Uint8Array.from(privateKey),
                  compressed
                )
              );
            };
          }).call(this);
        }).call(this, require("buffer").Buffer);
      },
      {
        "./secp256k1v3-lib/der": 14,
        "./secp256k1v3-lib/index": 15,
        buffer: 25,
        "ethereum-cryptography/secp256k1": 48,
      },
    ],
    14: [
      function (require, module, exports) {
        (function (Buffer) {
          (function () {
            "use strict";
            Object.defineProperty(exports, "__esModule", { value: true });
            var EC_PRIVKEY_EXPORT_DER_COMPRESSED = Buffer.from([
              48, 129, 211, 2, 1, 1, 4, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
              0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 160,
              129, 133, 48, 129, 130, 2, 1, 1, 48, 44, 6, 7, 42, 134, 72, 206,
              61, 1, 1, 2, 33, 0, 255, 255, 255, 255, 255, 255, 255, 255, 255,
              255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
              255, 255, 255, 255, 255, 254, 255, 255, 252, 47, 48, 6, 4, 1, 0,
              4, 1, 7, 4, 33, 2, 121, 190, 102, 126, 249, 220, 187, 172, 85,
              160, 98, 149, 206, 135, 11, 7, 2, 155, 252, 219, 45, 206, 40, 217,
              89, 242, 129, 91, 22, 248, 23, 152, 2, 33, 0, 255, 255, 255, 255,
              255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 254, 186,
              174, 220, 230, 175, 72, 160, 59, 191, 210, 94, 140, 208, 54, 65,
              65, 2, 1, 1, 161, 36, 3, 34, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
              0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            ]);
            var EC_PRIVKEY_EXPORT_DER_UNCOMPRESSED = Buffer.from([
              48, 130, 1, 19, 2, 1, 1, 4, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
              0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
              160, 129, 165, 48, 129, 162, 2, 1, 1, 48, 44, 6, 7, 42, 134, 72,
              206, 61, 1, 1, 2, 33, 0, 255, 255, 255, 255, 255, 255, 255, 255,
              255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
              255, 255, 255, 255, 255, 255, 254, 255, 255, 252, 47, 48, 6, 4, 1,
              0, 4, 1, 7, 4, 65, 4, 121, 190, 102, 126, 249, 220, 187, 172, 85,
              160, 98, 149, 206, 135, 11, 7, 2, 155, 252, 219, 45, 206, 40, 217,
              89, 242, 129, 91, 22, 248, 23, 152, 72, 58, 218, 119, 38, 163,
              196, 101, 93, 164, 251, 252, 14, 17, 8, 168, 253, 23, 180, 72,
              166, 133, 84, 25, 156, 71, 208, 143, 251, 16, 212, 184, 2, 33, 0,
              255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
              255, 255, 254, 186, 174, 220, 230, 175, 72, 160, 59, 191, 210, 94,
              140, 208, 54, 65, 65, 2, 1, 1, 161, 68, 3, 66, 0, 0, 0, 0, 0, 0,
              0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
              0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
              0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            ]);
            exports.privateKeyExport = function (
              privateKey,
              publicKey,
              compressed
            ) {
              if (compressed === void 0) {
                compressed = true;
              }
              var result = Buffer.from(
                compressed
                  ? EC_PRIVKEY_EXPORT_DER_COMPRESSED
                  : EC_PRIVKEY_EXPORT_DER_UNCOMPRESSED
              );
              privateKey.copy(result, compressed ? 8 : 9);
              publicKey.copy(result, compressed ? 181 : 214);
              return result;
            };
            exports.privateKeyImport = function (privateKey) {
              var length = privateKey.length;
              var index = 0;
              if (length < index + 1 || privateKey[index] !== 48) return null;
              index += 1;
              if (length < index + 1 || !(privateKey[index] & 128)) return null;
              var lenb = privateKey[index] & 127;
              index += 1;
              if (lenb < 1 || lenb > 2) return null;
              if (length < index + lenb) return null;
              var len =
                privateKey[index + lenb - 1] |
                (lenb > 1 ? privateKey[index + lenb - 2] << 8 : 0);
              index += lenb;
              if (length < index + len) return null;
              if (
                length < index + 3 ||
                privateKey[index] !== 2 ||
                privateKey[index + 1] !== 1 ||
                privateKey[index + 2] !== 1
              ) {
                return null;
              }
              index += 3;
              if (
                length < index + 2 ||
                privateKey[index] !== 4 ||
                privateKey[index + 1] > 32 ||
                length < index + 2 + privateKey[index + 1]
              ) {
                return null;
              }
              return privateKey.slice(
                index + 2,
                index + 2 + privateKey[index + 1]
              );
            };
            exports.signatureImportLax = function (signature) {
              var r = Buffer.alloc(32, 0);
              var s = Buffer.alloc(32, 0);
              var length = signature.length;
              var index = 0;
              if (signature[index++] !== 48) {
                return null;
              }
              var lenbyte = signature[index++];
              if (lenbyte & 128) {
                index += lenbyte - 128;
                if (index > length) {
                  return null;
                }
              }
              if (signature[index++] !== 2) {
                return null;
              }
              var rlen = signature[index++];
              if (rlen & 128) {
                lenbyte = rlen - 128;
                if (index + lenbyte > length) {
                  return null;
                }
                for (
                  ;
                  lenbyte > 0 && signature[index] === 0;
                  index += 1, lenbyte -= 1
                );
                for (rlen = 0; lenbyte > 0; index += 1, lenbyte -= 1)
                  rlen = (rlen << 8) + signature[index];
              }
              if (rlen > length - index) {
                return null;
              }
              var rindex = index;
              index += rlen;
              if (signature[index++] !== 2) {
                return null;
              }
              var slen = signature[index++];
              if (slen & 128) {
                lenbyte = slen - 128;
                if (index + lenbyte > length) {
                  return null;
                }
                for (
                  ;
                  lenbyte > 0 && signature[index] === 0;
                  index += 1, lenbyte -= 1
                );
                for (slen = 0; lenbyte > 0; index += 1, lenbyte -= 1)
                  slen = (slen << 8) + signature[index];
              }
              if (slen > length - index) {
                return null;
              }
              var sindex = index;
              index += slen;
              for (
                ;
                rlen > 0 && signature[rindex] === 0;
                rlen -= 1, rindex += 1
              );
              if (rlen > 32) {
                return null;
              }
              var rvalue = signature.slice(rindex, rindex + rlen);
              rvalue.copy(r, 32 - rvalue.length);
              for (
                ;
                slen > 0 && signature[sindex] === 0;
                slen -= 1, sindex += 1
              );
              if (slen > 32) {
                return null;
              }
              var svalue = signature.slice(sindex, sindex + slen);
              svalue.copy(s, 32 - svalue.length);
              return { r: r, s: s };
            };
          }).call(this);
        }).call(this, require("buffer").Buffer);
      },
      { buffer: 25 },
    ],
    15: [
      function (require, module, exports) {
        (function (Buffer) {
          (function () {
            "use strict";
            Object.defineProperty(exports, "__esModule", { value: true });
            var BN = require("bn.js");
            var EC = require("elliptic").ec;
            var ec = new EC("secp256k1");
            var ecparams = ec.curve;
            exports.privateKeyExport = function (privateKey, compressed) {
              if (compressed === void 0) {
                compressed = true;
              }
              var d = new BN(privateKey);
              if (d.ucmp(ecparams.n) >= 0) {
                throw new Error("couldn't export to DER format");
              }
              var point = ec.g.mul(d);
              return toPublicKey(point.getX(), point.getY(), compressed);
            };
            exports.privateKeyModInverse = function (privateKey) {
              var bn = new BN(privateKey);
              if (bn.ucmp(ecparams.n) >= 0 || bn.isZero()) {
                throw new Error("private key range is invalid");
              }
              return bn.invm(ecparams.n).toArrayLike(Buffer, "be", 32);
            };
            exports.signatureImport = function (sigObj) {
              var r = new BN(sigObj.r);
              if (r.ucmp(ecparams.n) >= 0) {
                r = new BN(0);
              }
              var s = new BN(sigObj.s);
              if (s.ucmp(ecparams.n) >= 0) {
                s = new BN(0);
              }
              return Buffer.concat([
                r.toArrayLike(Buffer, "be", 32),
                s.toArrayLike(Buffer, "be", 32),
              ]);
            };
            exports.ecdhUnsafe = function (publicKey, privateKey, compressed) {
              if (compressed === void 0) {
                compressed = true;
              }
              var point = ec.keyFromPublic(publicKey);
              var scalar = new BN(privateKey);
              if (scalar.ucmp(ecparams.n) >= 0 || scalar.isZero()) {
                throw new Error("scalar was invalid (zero or overflow)");
              }
              var shared = point.pub.mul(scalar);
              return toPublicKey(shared.getX(), shared.getY(), compressed);
            };
            var toPublicKey = function (x, y, compressed) {
              var publicKey;
              if (compressed) {
                publicKey = Buffer.alloc(33);
                publicKey[0] = y.isOdd() ? 3 : 2;
                x.toArrayLike(Buffer, "be", 32).copy(publicKey, 1);
              } else {
                publicKey = Buffer.alloc(65);
                publicKey[0] = 4;
                x.toArrayLike(Buffer, "be", 32).copy(publicKey, 1);
                y.toArrayLike(Buffer, "be", 32).copy(publicKey, 33);
              }
              return publicKey;
            };
          }).call(this);
        }).call(this, require("buffer").Buffer);
      },
      { "bn.js": 6, buffer: 25, elliptic: 28 },
    ],
    16: [
      function (require, module, exports) {
        (function (Buffer) {
          (function () {
            "use strict";
            Object.defineProperty(exports, "__esModule", { value: true });
            exports.hashPersonalMessage =
              exports.isValidSignature =
              exports.fromRpcSig =
              exports.toRpcSig =
              exports.ecrecover =
              exports.ecsign =
                void 0;
            var secp256k1 = require("./secp256k1v3-adapter");
            var BN = require("bn.js");
            var bytes_1 = require("./bytes");
            var hash_1 = require("./hash");
            exports.ecsign = function (msgHash, privateKey, chainId) {
              var sig = secp256k1.sign(msgHash, privateKey);
              var recovery = sig.recovery;
              var ret = {
                r: sig.signature.slice(0, 32),
                s: sig.signature.slice(32, 64),
                v: chainId ? recovery + (chainId * 2 + 35) : recovery + 27,
              };
              return ret;
            };
            exports.ecrecover = function (msgHash, v, r, s, chainId) {
              var signature = Buffer.concat(
                [bytes_1.setLength(r, 32), bytes_1.setLength(s, 32)],
                64
              );
              var recovery = calculateSigRecovery(v, chainId);
              if (!isValidSigRecovery(recovery)) {
                throw new Error("Invalid signature v value");
              }
              var senderPubKey = secp256k1.recover(
                msgHash,
                signature,
                recovery
              );
              return secp256k1.publicKeyConvert(senderPubKey, false).slice(1);
            };
            exports.toRpcSig = function (v, r, s, chainId) {
              var recovery = calculateSigRecovery(v, chainId);
              if (!isValidSigRecovery(recovery)) {
                throw new Error("Invalid signature v value");
              }
              return bytes_1.bufferToHex(
                Buffer.concat([
                  bytes_1.setLengthLeft(r, 32),
                  bytes_1.setLengthLeft(s, 32),
                  bytes_1.toBuffer(v),
                ])
              );
            };
            exports.fromRpcSig = function (sig) {
              var buf = bytes_1.toBuffer(sig);
              if (buf.length !== 65) {
                throw new Error("Invalid signature length");
              }
              var v = buf[64];
              if (v < 27) {
                v += 27;
              }
              return { v: v, r: buf.slice(0, 32), s: buf.slice(32, 64) };
            };
            exports.isValidSignature = function (
              v,
              r,
              s,
              homesteadOrLater,
              chainId
            ) {
              if (homesteadOrLater === void 0) {
                homesteadOrLater = true;
              }
              var SECP256K1_N_DIV_2 = new BN(
                "7fffffffffffffffffffffffffffffff5d576e7357a4501ddfe92f46681b20a0",
                16
              );
              var SECP256K1_N = new BN(
                "fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141",
                16
              );
              if (r.length !== 32 || s.length !== 32) {
                return false;
              }
              if (!isValidSigRecovery(calculateSigRecovery(v, chainId))) {
                return false;
              }
              var rBN = new BN(r);
              var sBN = new BN(s);
              if (
                rBN.isZero() ||
                rBN.gt(SECP256K1_N) ||
                sBN.isZero() ||
                sBN.gt(SECP256K1_N)
              ) {
                return false;
              }
              if (homesteadOrLater && sBN.cmp(SECP256K1_N_DIV_2) === 1) {
                return false;
              }
              return true;
            };
            exports.hashPersonalMessage = function (message) {
              var prefix = Buffer.from(
                "Ethereum Signed Message:\n" + message.length.toString(),
                "utf-8"
              );
              return hash_1.keccak(Buffer.concat([prefix, message]));
            };
            function calculateSigRecovery(v, chainId) {
              return chainId ? v - (2 * chainId + 35) : v - 27;
            }
            function isValidSigRecovery(recovery) {
              return recovery === 0 || recovery === 1;
            }
          }).call(this);
        }).call(this, require("buffer").Buffer);
      },
      {
        "./bytes": 8,
        "./hash": 10,
        "./secp256k1v3-adapter": 13,
        "bn.js": 6,
        buffer: 25,
      },
    ],
    17: [
      function (require, module, exports) {
        (function (global) {
          (function () {
            "use strict";
            var objectAssign = require("object-assign");
            function compare(a, b) {
              if (a === b) {
                return 0;
              }
              var x = a.length;
              var y = b.length;
              for (var i = 0, len = Math.min(x, y); i < len; ++i) {
                if (a[i] !== b[i]) {
                  x = a[i];
                  y = b[i];
                  break;
                }
              }
              if (x < y) {
                return -1;
              }
              if (y < x) {
                return 1;
              }
              return 0;
            }
            function isBuffer(b) {
              if (
                global.Buffer &&
                typeof global.Buffer.isBuffer === "function"
              ) {
                return global.Buffer.isBuffer(b);
              }
              return !!(b != null && b._isBuffer);
            }
            var util = require("util/");
            var hasOwn = Object.prototype.hasOwnProperty;
            var pSlice = Array.prototype.slice;
            var functionsHaveNames = (function () {
              return function foo() {}.name === "foo";
            })();
            function pToString(obj) {
              return Object.prototype.toString.call(obj);
            }
            function isView(arrbuf) {
              if (isBuffer(arrbuf)) {
                return false;
              }
              if (typeof global.ArrayBuffer !== "function") {
                return false;
              }
              if (typeof ArrayBuffer.isView === "function") {
                return ArrayBuffer.isView(arrbuf);
              }
              if (!arrbuf) {
                return false;
              }
              if (arrbuf instanceof DataView) {
                return true;
              }
              if (arrbuf.buffer && arrbuf.buffer instanceof ArrayBuffer) {
                return true;
              }
              return false;
            }
            var assert = (module.exports = ok);
            var regex = /\s*function\s+([^\(\s]*)\s*/;
            function getName(func) {
              if (!util.isFunction(func)) {
                return;
              }
              if (functionsHaveNames) {
                return func.name;
              }
              var str = func.toString();
              var match = str.match(regex);
              return match && match[1];
            }
            assert.AssertionError = function AssertionError(options) {
              this.name = "AssertionError";
              this.actual = options.actual;
              this.expected = options.expected;
              this.operator = options.operator;
              if (options.message) {
                this.message = options.message;
                this.generatedMessage = false;
              } else {
                this.message = getMessage(this);
                this.generatedMessage = true;
              }
              var stackStartFunction = options.stackStartFunction || fail;
              if (Error.captureStackTrace) {
                Error.captureStackTrace(this, stackStartFunction);
              } else {
                var err = new Error();
                if (err.stack) {
                  var out = err.stack;
                  var fn_name = getName(stackStartFunction);
                  var idx = out.indexOf("\n" + fn_name);
                  if (idx >= 0) {
                    var next_line = out.indexOf("\n", idx + 1);
                    out = out.substring(next_line + 1);
                  }
                  this.stack = out;
                }
              }
            };
            util.inherits(assert.AssertionError, Error);
            function truncate(s, n) {
              if (typeof s === "string") {
                return s.length < n ? s : s.slice(0, n);
              } else {
                return s;
              }
            }
            function inspect(something) {
              if (functionsHaveNames || !util.isFunction(something)) {
                return util.inspect(something);
              }
              var rawname = getName(something);
              var name = rawname ? ": " + rawname : "";
              return "[Function" + name + "]";
            }
            function getMessage(self) {
              return (
                truncate(inspect(self.actual), 128) +
                " " +
                self.operator +
                " " +
                truncate(inspect(self.expected), 128)
              );
            }
            function fail(
              actual,
              expected,
              message,
              operator,
              stackStartFunction
            ) {
              throw new assert.AssertionError({
                message: message,
                actual: actual,
                expected: expected,
                operator: operator,
                stackStartFunction: stackStartFunction,
              });
            }
            assert.fail = fail;
            function ok(value, message) {
              if (!value) fail(value, true, message, "==", assert.ok);
            }
            assert.ok = ok;
            assert.equal = function equal(actual, expected, message) {
              if (actual != expected)
                fail(actual, expected, message, "==", assert.equal);
            };
            assert.notEqual = function notEqual(actual, expected, message) {
              if (actual == expected) {
                fail(actual, expected, message, "!=", assert.notEqual);
              }
            };
            assert.deepEqual = function deepEqual(actual, expected, message) {
              if (!_deepEqual(actual, expected, false)) {
                fail(actual, expected, message, "deepEqual", assert.deepEqual);
              }
            };
            assert.deepStrictEqual = function deepStrictEqual(
              actual,
              expected,
              message
            ) {
              if (!_deepEqual(actual, expected, true)) {
                fail(
                  actual,
                  expected,
                  message,
                  "deepStrictEqual",
                  assert.deepStrictEqual
                );
              }
            };
            function _deepEqual(actual, expected, strict, memos) {
              if (actual === expected) {
                return true;
              } else if (isBuffer(actual) && isBuffer(expected)) {
                return compare(actual, expected) === 0;
              } else if (util.isDate(actual) && util.isDate(expected)) {
                return actual.getTime() === expected.getTime();
              } else if (util.isRegExp(actual) && util.isRegExp(expected)) {
                return (
                  actual.source === expected.source &&
                  actual.global === expected.global &&
                  actual.multiline === expected.multiline &&
                  actual.lastIndex === expected.lastIndex &&
                  actual.ignoreCase === expected.ignoreCase
                );
              } else if (
                (actual === null || typeof actual !== "object") &&
                (expected === null || typeof expected !== "object")
              ) {
                return strict ? actual === expected : actual == expected;
              } else if (
                isView(actual) &&
                isView(expected) &&
                pToString(actual) === pToString(expected) &&
                !(
                  actual instanceof Float32Array ||
                  actual instanceof Float64Array
                )
              ) {
                return (
                  compare(
                    new Uint8Array(actual.buffer),
                    new Uint8Array(expected.buffer)
                  ) === 0
                );
              } else if (isBuffer(actual) !== isBuffer(expected)) {
                return false;
              } else {
                memos = memos || { actual: [], expected: [] };
                var actualIndex = memos.actual.indexOf(actual);
                if (actualIndex !== -1) {
                  if (actualIndex === memos.expected.indexOf(expected)) {
                    return true;
                  }
                }
                memos.actual.push(actual);
                memos.expected.push(expected);
                return objEquiv(actual, expected, strict, memos);
              }
            }
            function isArguments(object) {
              return (
                Object.prototype.toString.call(object) == "[object Arguments]"
              );
            }
            function objEquiv(a, b, strict, actualVisitedObjects) {
              if (
                a === null ||
                a === undefined ||
                b === null ||
                b === undefined
              )
                return false;
              if (util.isPrimitive(a) || util.isPrimitive(b)) return a === b;
              if (
                strict &&
                Object.getPrototypeOf(a) !== Object.getPrototypeOf(b)
              )
                return false;
              var aIsArgs = isArguments(a);
              var bIsArgs = isArguments(b);
              if ((aIsArgs && !bIsArgs) || (!aIsArgs && bIsArgs)) return false;
              if (aIsArgs) {
                a = pSlice.call(a);
                b = pSlice.call(b);
                return _deepEqual(a, b, strict);
              }
              var ka = objectKeys(a);
              var kb = objectKeys(b);
              var key, i;
              if (ka.length !== kb.length) return false;
              ka.sort();
              kb.sort();
              for (i = ka.length - 1; i >= 0; i--) {
                if (ka[i] !== kb[i]) return false;
              }
              for (i = ka.length - 1; i >= 0; i--) {
                key = ka[i];
                if (!_deepEqual(a[key], b[key], strict, actualVisitedObjects))
                  return false;
              }
              return true;
            }
            assert.notDeepEqual = function notDeepEqual(
              actual,
              expected,
              message
            ) {
              if (_deepEqual(actual, expected, false)) {
                fail(
                  actual,
                  expected,
                  message,
                  "notDeepEqual",
                  assert.notDeepEqual
                );
              }
            };
            assert.notDeepStrictEqual = notDeepStrictEqual;
            function notDeepStrictEqual(actual, expected, message) {
              if (_deepEqual(actual, expected, true)) {
                fail(
                  actual,
                  expected,
                  message,
                  "notDeepStrictEqual",
                  notDeepStrictEqual
                );
              }
            }
            assert.strictEqual = function strictEqual(
              actual,
              expected,
              message
            ) {
              if (actual !== expected) {
                fail(actual, expected, message, "===", assert.strictEqual);
              }
            };
            assert.notStrictEqual = function notStrictEqual(
              actual,
              expected,
              message
            ) {
              if (actual === expected) {
                fail(actual, expected, message, "!==", assert.notStrictEqual);
              }
            };
            function expectedException(actual, expected) {
              if (!actual || !expected) {
                return false;
              }
              if (
                Object.prototype.toString.call(expected) == "[object RegExp]"
              ) {
                return expected.test(actual);
              }
              try {
                if (actual instanceof expected) {
                  return true;
                }
              } catch (e) {}
              if (Error.isPrototypeOf(expected)) {
                return false;
              }
              return expected.call({}, actual) === true;
            }
            function _tryBlock(block) {
              var error;
              try {
                block();
              } catch (e) {
                error = e;
              }
              return error;
            }
            function _throws(shouldThrow, block, expected, message) {
              var actual;
              if (typeof block !== "function") {
                throw new TypeError('"block" argument must be a function');
              }
              if (typeof expected === "string") {
                message = expected;
                expected = null;
              }
              actual = _tryBlock(block);
              message =
                (expected && expected.name
                  ? " (" + expected.name + ")."
                  : ".") + (message ? " " + message : ".");
              if (shouldThrow && !actual) {
                fail(actual, expected, "Missing expected exception" + message);
              }
              var userProvidedMessage = typeof message === "string";
              var isUnwantedException = !shouldThrow && util.isError(actual);
              var isUnexpectedException = !shouldThrow && actual && !expected;
              if (
                (isUnwantedException &&
                  userProvidedMessage &&
                  expectedException(actual, expected)) ||
                isUnexpectedException
              ) {
                fail(actual, expected, "Got unwanted exception" + message);
              }
              if (
                (shouldThrow &&
                  actual &&
                  expected &&
                  !expectedException(actual, expected)) ||
                (!shouldThrow && actual)
              ) {
                throw actual;
              }
            }
            assert.throws = function (block, error, message) {
              _throws(true, block, error, message);
            };
            assert.doesNotThrow = function (block, error, message) {
              _throws(false, block, error, message);
            };
            assert.ifError = function (err) {
              if (err) throw err;
            };
            function strict(value, message) {
              if (!value) fail(value, true, message, "==", strict);
            }
            assert.strict = objectAssign(strict, assert, {
              equal: assert.strictEqual,
              deepEqual: assert.deepStrictEqual,
              notEqual: assert.notStrictEqual,
              notDeepEqual: assert.notDeepStrictEqual,
            });
            assert.strict.strict = assert.strict;
            var objectKeys =
              Object.keys ||
              function (obj) {
                var keys = [];
                for (var key in obj) {
                  if (hasOwn.call(obj, key)) keys.push(key);
                }
                return keys;
              };
          }).call(this);
        }).call(
          this,
          typeof global !== "undefined"
            ? global
            : typeof self !== "undefined"
            ? self
            : typeof window !== "undefined"
            ? window
            : {}
        );
      },
      { "object-assign": 121, "util/": 20 },
    ],
    18: [
      function (require, module, exports) {
        if (typeof Object.create === "function") {
          module.exports = function inherits(ctor, superCtor) {
            ctor.super_ = superCtor;
            ctor.prototype = Object.create(superCtor.prototype, {
              constructor: {
                value: ctor,
                enumerable: false,
                writable: true,
                configurable: true,
              },
            });
          };
        } else {
          module.exports = function inherits(ctor, superCtor) {
            ctor.super_ = superCtor;
            var TempCtor = function () {};
            TempCtor.prototype = superCtor.prototype;
            ctor.prototype = new TempCtor();
            ctor.prototype.constructor = ctor;
          };
        }
      },
      {},
    ],
    19: [
      function (require, module, exports) {
        module.exports = function isBuffer(arg) {
          return (
            arg &&
            typeof arg === "object" &&
            typeof arg.copy === "function" &&
            typeof arg.fill === "function" &&
            typeof arg.readUInt8 === "function"
          );
        };
      },
      {},
    ],
    20: [
      function (require, module, exports) {
        (function (process, global) {
          (function () {
            var formatRegExp = /%[sdj%]/g;
            exports.format = function (f) {
              if (!isString(f)) {
                var objects = [];
                for (var i = 0; i < arguments.length; i++) {
                  objects.push(inspect(arguments[i]));
                }
                return objects.join(" ");
              }
              var i = 1;
              var args = arguments;
              var len = args.length;
              var str = String(f).replace(formatRegExp, function (x) {
                if (x === "%%") return "%";
                if (i >= len) return x;
                switch (x) {
                  case "%s":
                    return String(args[i++]);
                  case "%d":
                    return Number(args[i++]);
                  case "%j":
                    try {
                      return JSON.stringify(args[i++]);
                    } catch (_) {
                      return "[Circular]";
                    }
                  default:
                    return x;
                }
              });
              for (var x = args[i]; i < len; x = args[++i]) {
                if (isNull(x) || !isObject(x)) {
                  str += " " + x;
                } else {
                  str += " " + inspect(x);
                }
              }
              return str;
            };
            exports.deprecate = function (fn, msg) {
              if (isUndefined(global.process)) {
                return function () {
                  return exports.deprecate(fn, msg).apply(this, arguments);
                };
              }
              if (process.noDeprecation === true) {
                return fn;
              }
              var warned = false;
              function deprecated() {
                if (!warned) {
                  if (process.throwDeprecation) {
                    throw new Error(msg);
                  } else if (process.traceDeprecation) {
                    console.trace(msg);
                  } else {
                    console.error(msg);
                  }
                  warned = true;
                }
                return fn.apply(this, arguments);
              }
              return deprecated;
            };
            var debugs = {};
            var debugEnviron;
            exports.debuglog = function (set) {
              if (isUndefined(debugEnviron))
                debugEnviron = process.env.NODE_DEBUG || "";
              set = set.toUpperCase();
              if (!debugs[set]) {
                if (new RegExp("\\b" + set + "\\b", "i").test(debugEnviron)) {
                  var pid = process.pid;
                  debugs[set] = function () {
                    var msg = exports.format.apply(exports, arguments);
                    console.error("%s %d: %s", set, pid, msg);
                  };
                } else {
                  debugs[set] = function () {};
                }
              }
              return debugs[set];
            };
            function inspect(obj, opts) {
              var ctx = { seen: [], stylize: stylizeNoColor };
              if (arguments.length >= 3) ctx.depth = arguments[2];
              if (arguments.length >= 4) ctx.colors = arguments[3];
              if (isBoolean(opts)) {
                ctx.showHidden = opts;
              } else if (opts) {
                exports._extend(ctx, opts);
              }
              if (isUndefined(ctx.showHidden)) ctx.showHidden = false;
              if (isUndefined(ctx.depth)) ctx.depth = 2;
              if (isUndefined(ctx.colors)) ctx.colors = false;
              if (isUndefined(ctx.customInspect)) ctx.customInspect = true;
              if (ctx.colors) ctx.stylize = stylizeWithColor;
              return formatValue(ctx, obj, ctx.depth);
            }
            exports.inspect = inspect;
            inspect.colors = {
              bold: [1, 22],
              italic: [3, 23],
              underline: [4, 24],
              inverse: [7, 27],
              white: [37, 39],
              grey: [90, 39],
              black: [30, 39],
              blue: [34, 39],
              cyan: [36, 39],
              green: [32, 39],
              magenta: [35, 39],
              red: [31, 39],
              yellow: [33, 39],
            };
            inspect.styles = {
              special: "cyan",
              number: "yellow",
              boolean: "yellow",
              undefined: "grey",
              null: "bold",
              string: "green",
              date: "magenta",
              regexp: "red",
            };
            function stylizeWithColor(str, styleType) {
              var style = inspect.styles[styleType];
              if (style) {
                return (
                  "[" +
                  inspect.colors[style][0] +
                  "m" +
                  str +
                  "[" +
                  inspect.colors[style][1] +
                  "m"
                );
              } else {
                return str;
              }
            }
            function stylizeNoColor(str, styleType) {
              return str;
            }
            function arrayToHash(array) {
              var hash = {};
              array.forEach(function (val, idx) {
                hash[val] = true;
              });
              return hash;
            }
            function formatValue(ctx, value, recurseTimes) {
              if (
                ctx.customInspect &&
                value &&
                isFunction(value.inspect) &&
                value.inspect !== exports.inspect &&
                !(value.constructor && value.constructor.prototype === value)
              ) {
                var ret = value.inspect(recurseTimes, ctx);
                if (!isString(ret)) {
                  ret = formatValue(ctx, ret, recurseTimes);
                }
                return ret;
              }
              var primitive = formatPrimitive(ctx, value);
              if (primitive) {
                return primitive;
              }
              var keys = Object.keys(value);
              var visibleKeys = arrayToHash(keys);
              if (ctx.showHidden) {
                keys = Object.getOwnPropertyNames(value);
              }
              if (
                isError(value) &&
                (keys.indexOf("message") >= 0 ||
                  keys.indexOf("description") >= 0)
              ) {
                return formatError(value);
              }
              if (keys.length === 0) {
                if (isFunction(value)) {
                  var name = value.name ? ": " + value.name : "";
                  return ctx.stylize("[Function" + name + "]", "special");
                }
                if (isRegExp(value)) {
                  return ctx.stylize(
                    RegExp.prototype.toString.call(value),
                    "regexp"
                  );
                }
                if (isDate(value)) {
                  return ctx.stylize(
                    Date.prototype.toString.call(value),
                    "date"
                  );
                }
                if (isError(value)) {
                  return formatError(value);
                }
              }
              var base = "",
                array = false,
                braces = ["{", "}"];
              if (isArray(value)) {
                array = true;
                braces = ["[", "]"];
              }
              if (isFunction(value)) {
                var n = value.name ? ": " + value.name : "";
                base = " [Function" + n + "]";
              }
              if (isRegExp(value)) {
                base = " " + RegExp.prototype.toString.call(value);
              }
              if (isDate(value)) {
                base = " " + Date.prototype.toUTCString.call(value);
              }
              if (isError(value)) {
                base = " " + formatError(value);
              }
              if (keys.length === 0 && (!array || value.length == 0)) {
                return braces[0] + base + braces[1];
              }
              if (recurseTimes < 0) {
                if (isRegExp(value)) {
                  return ctx.stylize(
                    RegExp.prototype.toString.call(value),
                    "regexp"
                  );
                } else {
                  return ctx.stylize("[Object]", "special");
                }
              }
              ctx.seen.push(value);
              var output;
              if (array) {
                output = formatArray(
                  ctx,
                  value,
                  recurseTimes,
                  visibleKeys,
                  keys
                );
              } else {
                output = keys.map(function (key) {
                  return formatProperty(
                    ctx,
                    value,
                    recurseTimes,
                    visibleKeys,
                    key,
                    array
                  );
                });
              }
              ctx.seen.pop();
              return reduceToSingleString(output, base, braces);
            }
            function formatPrimitive(ctx, value) {
              if (isUndefined(value))
                return ctx.stylize("undefined", "undefined");
              if (isString(value)) {
                var simple =
                  "'" +
                  JSON.stringify(value)
                    .replace(/^"|"$/g, "")
                    .replace(/'/g, "\\'")
                    .replace(/\\"/g, '"') +
                  "'";
                return ctx.stylize(simple, "string");
              }
              if (isNumber(value)) return ctx.stylize("" + value, "number");
              if (isBoolean(value)) return ctx.stylize("" + value, "boolean");
              if (isNull(value)) return ctx.stylize("null", "null");
            }
            function formatError(value) {
              return "[" + Error.prototype.toString.call(value) + "]";
            }
            function formatArray(ctx, value, recurseTimes, visibleKeys, keys) {
              var output = [];
              for (var i = 0, l = value.length; i < l; ++i) {
                if (hasOwnProperty(value, String(i))) {
                  output.push(
                    formatProperty(
                      ctx,
                      value,
                      recurseTimes,
                      visibleKeys,
                      String(i),
                      true
                    )
                  );
                } else {
                  output.push("");
                }
              }
              keys.forEach(function (key) {
                if (!key.match(/^\d+$/)) {
                  output.push(
                    formatProperty(
                      ctx,
                      value,
                      recurseTimes,
                      visibleKeys,
                      key,
                      true
                    )
                  );
                }
              });
              return output;
            }
            function formatProperty(
              ctx,
              value,
              recurseTimes,
              visibleKeys,
              key,
              array
            ) {
              var name, str, desc;
              desc = Object.getOwnPropertyDescriptor(value, key) || {
                value: value[key],
              };
              if (desc.get) {
                if (desc.set) {
                  str = ctx.stylize("[Getter/Setter]", "special");
                } else {
                  str = ctx.stylize("[Getter]", "special");
                }
              } else {
                if (desc.set) {
                  str = ctx.stylize("[Setter]", "special");
                }
              }
              if (!hasOwnProperty(visibleKeys, key)) {
                name = "[" + key + "]";
              }
              if (!str) {
                if (ctx.seen.indexOf(desc.value) < 0) {
                  if (isNull(recurseTimes)) {
                    str = formatValue(ctx, desc.value, null);
                  } else {
                    str = formatValue(ctx, desc.value, recurseTimes - 1);
                  }
                  if (str.indexOf("\n") > -1) {
                    if (array) {
                      str = str
                        .split("\n")
                        .map(function (line) {
                          return "  " + line;
                        })
                        .join("\n")
                        .substr(2);
                    } else {
                      str =
                        "\n" +
                        str
                          .split("\n")
                          .map(function (line) {
                            return "   " + line;
                          })
                          .join("\n");
                    }
                  }
                } else {
                  str = ctx.stylize("[Circular]", "special");
                }
              }
              if (isUndefined(name)) {
                if (array && key.match(/^\d+$/)) {
                  return str;
                }
                name = JSON.stringify("" + key);
                if (name.match(/^"([a-zA-Z_][a-zA-Z_0-9]*)"$/)) {
                  name = name.substr(1, name.length - 2);
                  name = ctx.stylize(name, "name");
                } else {
                  name = name
                    .replace(/'/g, "\\'")
                    .replace(/\\"/g, '"')
                    .replace(/(^"|"$)/g, "'");
                  name = ctx.stylize(name, "string");
                }
              }
              return name + ": " + str;
            }
            function reduceToSingleString(output, base, braces) {
              var numLinesEst = 0;
              var length = output.reduce(function (prev, cur) {
                numLinesEst++;
                if (cur.indexOf("\n") >= 0) numLinesEst++;
                return prev + cur.replace(/\u001b\[\d\d?m/g, "").length + 1;
              }, 0);
              if (length > 60) {
                return (
                  braces[0] +
                  (base === "" ? "" : base + "\n ") +
                  " " +
                  output.join(",\n  ") +
                  " " +
                  braces[1]
                );
              }
              return (
                braces[0] + base + " " + output.join(", ") + " " + braces[1]
              );
            }
            function isArray(ar) {
              return Array.isArray(ar);
            }
            exports.isArray = isArray;
            function isBoolean(arg) {
              return typeof arg === "boolean";
            }
            exports.isBoolean = isBoolean;
            function isNull(arg) {
              return arg === null;
            }
            exports.isNull = isNull;
            function isNullOrUndefined(arg) {
              return arg == null;
            }
            exports.isNullOrUndefined = isNullOrUndefined;
            function isNumber(arg) {
              return typeof arg === "number";
            }
            exports.isNumber = isNumber;
            function isString(arg) {
              return typeof arg === "string";
            }
            exports.isString = isString;
            function isSymbol(arg) {
              return typeof arg === "symbol";
            }
            exports.isSymbol = isSymbol;
            function isUndefined(arg) {
              return arg === void 0;
            }
            exports.isUndefined = isUndefined;
            function isRegExp(re) {
              return isObject(re) && objectToString(re) === "[object RegExp]";
            }
            exports.isRegExp = isRegExp;
            function isObject(arg) {
              return typeof arg === "object" && arg !== null;
            }
            exports.isObject = isObject;
            function isDate(d) {
              return isObject(d) && objectToString(d) === "[object Date]";
            }
            exports.isDate = isDate;
            function isError(e) {
              return (
                isObject(e) &&
                (objectToString(e) === "[object Error]" || e instanceof Error)
              );
            }
            exports.isError = isError;
            function isFunction(arg) {
              return typeof arg === "function";
            }
            exports.isFunction = isFunction;
            function isPrimitive(arg) {
              return (
                arg === null ||
                typeof arg === "boolean" ||
                typeof arg === "number" ||
                typeof arg === "string" ||
                typeof arg === "symbol" ||
                typeof arg === "undefined"
              );
            }
            exports.isPrimitive = isPrimitive;
            exports.isBuffer = require("./support/isBuffer");
            function objectToString(o) {
              return Object.prototype.toString.call(o);
            }
            function pad(n) {
              return n < 10 ? "0" + n.toString(10) : n.toString(10);
            }
            var months = [
              "Jan",
              "Feb",
              "Mar",
              "Apr",
              "May",
              "Jun",
              "Jul",
              "Aug",
              "Sep",
              "Oct",
              "Nov",
              "Dec",
            ];
            function timestamp() {
              var d = new Date();
              var time = [
                pad(d.getHours()),
                pad(d.getMinutes()),
                pad(d.getSeconds()),
              ].join(":");
              return [d.getDate(), months[d.getMonth()], time].join(" ");
            }
            exports.log = function () {
              console.log(
                "%s - %s",
                timestamp(),
                exports.format.apply(exports, arguments)
              );
            };
            exports.inherits = require("inherits");
            exports._extend = function (origin, add) {
              if (!add || !isObject(add)) return origin;
              var keys = Object.keys(add);
              var i = keys.length;
              while (i--) {
                origin[keys[i]] = add[keys[i]];
              }
              return origin;
            };
            function hasOwnProperty(obj, prop) {
              return Object.prototype.hasOwnProperty.call(obj, prop);
            }
          }).call(this);
        }).call(
          this,
          require("_process"),
          typeof global !== "undefined"
            ? global
            : typeof self !== "undefined"
            ? self
            : typeof window !== "undefined"
            ? window
            : {}
        );
      },
      { "./support/isBuffer": 19, _process: 122, inherits: 18 },
    ],
    21: [
      function (require, module, exports) {
        "use strict";
        exports.byteLength = byteLength;
        exports.toByteArray = toByteArray;
        exports.fromByteArray = fromByteArray;
        var lookup = [];
        var revLookup = [];
        var Arr = typeof Uint8Array !== "undefined" ? Uint8Array : Array;
        var code =
          "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        for (var i = 0, len = code.length; i < len; ++i) {
          lookup[i] = code[i];
          revLookup[code.charCodeAt(i)] = i;
        }
        revLookup["-".charCodeAt(0)] = 62;
        revLookup["_".charCodeAt(0)] = 63;
        function getLens(b64) {
          var len = b64.length;
          if (len % 4 > 0) {
            throw new Error("Invalid string. Length must be a multiple of 4");
          }
          var validLen = b64.indexOf("=");
          if (validLen === -1) validLen = len;
          var placeHoldersLen = validLen === len ? 0 : 4 - (validLen % 4);
          return [validLen, placeHoldersLen];
        }
        function byteLength(b64) {
          var lens = getLens(b64);
          var validLen = lens[0];
          var placeHoldersLen = lens[1];
          return ((validLen + placeHoldersLen) * 3) / 4 - placeHoldersLen;
        }
        function _byteLength(b64, validLen, placeHoldersLen) {
          return ((validLen + placeHoldersLen) * 3) / 4 - placeHoldersLen;
        }
        function toByteArray(b64) {
          var tmp;
          var lens = getLens(b64);
          var validLen = lens[0];
          var placeHoldersLen = lens[1];
          var arr = new Arr(_byteLength(b64, validLen, placeHoldersLen));
          var curByte = 0;
          var len = placeHoldersLen > 0 ? validLen - 4 : validLen;
          var i;
          for (i = 0; i < len; i += 4) {
            tmp =
              (revLookup[b64.charCodeAt(i)] << 18) |
              (revLookup[b64.charCodeAt(i + 1)] << 12) |
              (revLookup[b64.charCodeAt(i + 2)] << 6) |
              revLookup[b64.charCodeAt(i + 3)];
            arr[curByte++] = (tmp >> 16) & 255;
            arr[curByte++] = (tmp >> 8) & 255;
            arr[curByte++] = tmp & 255;
          }
          if (placeHoldersLen === 2) {
            tmp =
              (revLookup[b64.charCodeAt(i)] << 2) |
              (revLookup[b64.charCodeAt(i + 1)] >> 4);
            arr[curByte++] = tmp & 255;
          }
          if (placeHoldersLen === 1) {
            tmp =
              (revLookup[b64.charCodeAt(i)] << 10) |
              (revLookup[b64.charCodeAt(i + 1)] << 4) |
              (revLookup[b64.charCodeAt(i + 2)] >> 2);
            arr[curByte++] = (tmp >> 8) & 255;
            arr[curByte++] = tmp & 255;
          }
          return arr;
        }
        function tripletToBase64(num) {
          return (
            lookup[(num >> 18) & 63] +
            lookup[(num >> 12) & 63] +
            lookup[(num >> 6) & 63] +
            lookup[num & 63]
          );
        }
        function encodeChunk(uint8, start, end) {
          var tmp;
          var output = [];
          for (var i = start; i < end; i += 3) {
            tmp =
              ((uint8[i] << 16) & 16711680) +
              ((uint8[i + 1] << 8) & 65280) +
              (uint8[i + 2] & 255);
            output.push(tripletToBase64(tmp));
          }
          return output.join("");
        }
        function fromByteArray(uint8) {
          var tmp;
          var len = uint8.length;
          var extraBytes = len % 3;
          var parts = [];
          var maxChunkLength = 16383;
          for (
            var i = 0, len2 = len - extraBytes;
            i < len2;
            i += maxChunkLength
          ) {
            parts.push(
              encodeChunk(
                uint8,
                i,
                i + maxChunkLength > len2 ? len2 : i + maxChunkLength
              )
            );
          }
          if (extraBytes === 1) {
            tmp = uint8[len - 1];
            parts.push(lookup[tmp >> 2] + lookup[(tmp << 4) & 63] + "==");
          } else if (extraBytes === 2) {
            tmp = (uint8[len - 2] << 8) + uint8[len - 1];
            parts.push(
              lookup[tmp >> 10] +
                lookup[(tmp >> 4) & 63] +
                lookup[(tmp << 2) & 63] +
                "="
            );
          }
          return parts.join("");
        }
      },
      {},
    ],
    22: [
      function (require, module, exports) {
        (function (module, exports) {
          "use strict";
          function assert(val, msg) {
            if (!val) throw new Error(msg || "Assertion failed");
          }
          function inherits(ctor, superCtor) {
            ctor.super_ = superCtor;
            var TempCtor = function () {};
            TempCtor.prototype = superCtor.prototype;
            ctor.prototype = new TempCtor();
            ctor.prototype.constructor = ctor;
          }
          function BN(number, base, endian) {
            if (BN.isBN(number)) {
              return number;
            }
            this.negative = 0;
            this.words = null;
            this.length = 0;
            this.red = null;
            if (number !== null) {
              if (base === "le" || base === "be") {
                endian = base;
                base = 10;
              }
              this._init(number || 0, base || 10, endian || "be");
            }
          }
          if (typeof module === "object") {
            module.exports = BN;
          } else {
            exports.BN = BN;
          }
          BN.BN = BN;
          BN.wordSize = 26;
          var Buffer;
          try {
            if (
              typeof window !== "undefined" &&
              typeof window.Buffer !== "undefined"
            ) {
              Buffer = window.Buffer;
            } else {
              Buffer = require("buffer").Buffer;
            }
          } catch (e) {}
          BN.isBN = function isBN(num) {
            if (num instanceof BN) {
              return true;
            }
            return (
              num !== null &&
              typeof num === "object" &&
              num.constructor.wordSize === BN.wordSize &&
              Array.isArray(num.words)
            );
          };
          BN.max = function max(left, right) {
            if (left.cmp(right) > 0) return left;
            return right;
          };
          BN.min = function min(left, right) {
            if (left.cmp(right) < 0) return left;
            return right;
          };
          BN.prototype._init = function init(number, base, endian) {
            if (typeof number === "number") {
              return this._initNumber(number, base, endian);
            }
            if (typeof number === "object") {
              return this._initArray(number, base, endian);
            }
            if (base === "hex") {
              base = 16;
            }
            assert(base === (base | 0) && base >= 2 && base <= 36);
            number = number.toString().replace(/\s+/g, "");
            var start = 0;
            if (number[0] === "-") {
              start++;
              this.negative = 1;
            }
            if (start < number.length) {
              if (base === 16) {
                this._parseHex(number, start, endian);
              } else {
                this._parseBase(number, base, start);
                if (endian === "le") {
                  this._initArray(this.toArray(), base, endian);
                }
              }
            }
          };
          BN.prototype._initNumber = function _initNumber(
            number,
            base,
            endian
          ) {
            if (number < 0) {
              this.negative = 1;
              number = -number;
            }
            if (number < 67108864) {
              this.words = [number & 67108863];
              this.length = 1;
            } else if (number < 4503599627370496) {
              this.words = [number & 67108863, (number / 67108864) & 67108863];
              this.length = 2;
            } else {
              assert(number < 9007199254740992);
              this.words = [
                number & 67108863,
                (number / 67108864) & 67108863,
                1,
              ];
              this.length = 3;
            }
            if (endian !== "le") return;
            this._initArray(this.toArray(), base, endian);
          };
          BN.prototype._initArray = function _initArray(number, base, endian) {
            assert(typeof number.length === "number");
            if (number.length <= 0) {
              this.words = [0];
              this.length = 1;
              return this;
            }
            this.length = Math.ceil(number.length / 3);
            this.words = new Array(this.length);
            for (var i = 0; i < this.length; i++) {
              this.words[i] = 0;
            }
            var j, w;
            var off = 0;
            if (endian === "be") {
              for (i = number.length - 1, j = 0; i >= 0; i -= 3) {
                w = number[i] | (number[i - 1] << 8) | (number[i - 2] << 16);
                this.words[j] |= (w << off) & 67108863;
                this.words[j + 1] = (w >>> (26 - off)) & 67108863;
                off += 24;
                if (off >= 26) {
                  off -= 26;
                  j++;
                }
              }
            } else if (endian === "le") {
              for (i = 0, j = 0; i < number.length; i += 3) {
                w = number[i] | (number[i + 1] << 8) | (number[i + 2] << 16);
                this.words[j] |= (w << off) & 67108863;
                this.words[j + 1] = (w >>> (26 - off)) & 67108863;
                off += 24;
                if (off >= 26) {
                  off -= 26;
                  j++;
                }
              }
            }
            return this._strip();
          };
          function parseHex4Bits(string, index) {
            var c = string.charCodeAt(index);
            if (c >= 48 && c <= 57) {
              return c - 48;
            } else if (c >= 65 && c <= 70) {
              return c - 55;
            } else if (c >= 97 && c <= 102) {
              return c - 87;
            } else {
              assert(false, "Invalid character in " + string);
            }
          }
          function parseHexByte(string, lowerBound, index) {
            var r = parseHex4Bits(string, index);
            if (index - 1 >= lowerBound) {
              r |= parseHex4Bits(string, index - 1) << 4;
            }
            return r;
          }
          BN.prototype._parseHex = function _parseHex(number, start, endian) {
            this.length = Math.ceil((number.length - start) / 6);
            this.words = new Array(this.length);
            for (var i = 0; i < this.length; i++) {
              this.words[i] = 0;
            }
            var off = 0;
            var j = 0;
            var w;
            if (endian === "be") {
              for (i = number.length - 1; i >= start; i -= 2) {
                w = parseHexByte(number, start, i) << off;
                this.words[j] |= w & 67108863;
                if (off >= 18) {
                  off -= 18;
                  j += 1;
                  this.words[j] |= w >>> 26;
                } else {
                  off += 8;
                }
              }
            } else {
              var parseLength = number.length - start;
              for (
                i = parseLength % 2 === 0 ? start + 1 : start;
                i < number.length;
                i += 2
              ) {
                w = parseHexByte(number, start, i) << off;
                this.words[j] |= w & 67108863;
                if (off >= 18) {
                  off -= 18;
                  j += 1;
                  this.words[j] |= w >>> 26;
                } else {
                  off += 8;
                }
              }
            }
            this._strip();
          };
          function parseBase(str, start, end, mul) {
            var r = 0;
            var b = 0;
            var len = Math.min(str.length, end);
            for (var i = start; i < len; i++) {
              var c = str.charCodeAt(i) - 48;
              r *= mul;
              if (c >= 49) {
                b = c - 49 + 10;
              } else if (c >= 17) {
                b = c - 17 + 10;
              } else {
                b = c;
              }
              assert(c >= 0 && b < mul, "Invalid character");
              r += b;
            }
            return r;
          }
          BN.prototype._parseBase = function _parseBase(number, base, start) {
            this.words = [0];
            this.length = 1;
            for (
              var limbLen = 0, limbPow = 1;
              limbPow <= 67108863;
              limbPow *= base
            ) {
              limbLen++;
            }
            limbLen--;
            limbPow = (limbPow / base) | 0;
            var total = number.length - start;
            var mod = total % limbLen;
            var end = Math.min(total, total - mod) + start;
            var word = 0;
            for (var i = start; i < end; i += limbLen) {
              word = parseBase(number, i, i + limbLen, base);
              this.imuln(limbPow);
              if (this.words[0] + word < 67108864) {
                this.words[0] += word;
              } else {
                this._iaddn(word);
              }
            }
            if (mod !== 0) {
              var pow = 1;
              word = parseBase(number, i, number.length, base);
              for (i = 0; i < mod; i++) {
                pow *= base;
              }
              this.imuln(pow);
              if (this.words[0] + word < 67108864) {
                this.words[0] += word;
              } else {
                this._iaddn(word);
              }
            }
            this._strip();
          };
          BN.prototype.copy = function copy(dest) {
            dest.words = new Array(this.length);
            for (var i = 0; i < this.length; i++) {
              dest.words[i] = this.words[i];
            }
            dest.length = this.length;
            dest.negative = this.negative;
            dest.red = this.red;
          };
          function move(dest, src) {
            dest.words = src.words;
            dest.length = src.length;
            dest.negative = src.negative;
            dest.red = src.red;
          }
          BN.prototype._move = function _move(dest) {
            move(dest, this);
          };
          BN.prototype.clone = function clone() {
            var r = new BN(null);
            this.copy(r);
            return r;
          };
          BN.prototype._expand = function _expand(size) {
            while (this.length < size) {
              this.words[this.length++] = 0;
            }
            return this;
          };
          BN.prototype._strip = function strip() {
            while (this.length > 1 && this.words[this.length - 1] === 0) {
              this.length--;
            }
            return this._normSign();
          };
          BN.prototype._normSign = function _normSign() {
            if (this.length === 1 && this.words[0] === 0) {
              this.negative = 0;
            }
            return this;
          };
          if (
            typeof Symbol !== "undefined" &&
            typeof Symbol.for === "function"
          ) {
            try {
              BN.prototype[Symbol.for("nodejs.util.inspect.custom")] = inspect;
            } catch (e) {
              BN.prototype.inspect = inspect;
            }
          } else {
            BN.prototype.inspect = inspect;
          }
          function inspect() {
            return (this.red ? "<BN-R: " : "<BN: ") + this.toString(16) + ">";
          }
          var zeros = [
            "",
            "0",
            "00",
            "000",
            "0000",
            "00000",
            "000000",
            "0000000",
            "00000000",
            "000000000",
            "0000000000",
            "00000000000",
            "000000000000",
            "0000000000000",
            "00000000000000",
            "000000000000000",
            "0000000000000000",
            "00000000000000000",
            "000000000000000000",
            "0000000000000000000",
            "00000000000000000000",
            "000000000000000000000",
            "0000000000000000000000",
            "00000000000000000000000",
            "000000000000000000000000",
            "0000000000000000000000000",
          ];
          var groupSizes = [
            0, 0, 25, 16, 12, 11, 10, 9, 8, 8, 7, 7, 7, 7, 6, 6, 6, 6, 6, 6, 6,
            5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
          ];
          var groupBases = [
            0, 0, 33554432, 43046721, 16777216, 48828125, 60466176, 40353607,
            16777216, 43046721, 1e7, 19487171, 35831808, 62748517, 7529536,
            11390625, 16777216, 24137569, 34012224, 47045881, 64e6, 4084101,
            5153632, 6436343, 7962624, 9765625, 11881376, 14348907, 17210368,
            20511149, 243e5, 28629151, 33554432, 39135393, 45435424, 52521875,
            60466176,
          ];
          BN.prototype.toString = function toString(base, padding) {
            base = base || 10;
            padding = padding | 0 || 1;
            var out;
            if (base === 16 || base === "hex") {
              out = "";
              var off = 0;
              var carry = 0;
              for (var i = 0; i < this.length; i++) {
                var w = this.words[i];
                var word = (((w << off) | carry) & 16777215).toString(16);
                carry = (w >>> (24 - off)) & 16777215;
                if (carry !== 0 || i !== this.length - 1) {
                  out = zeros[6 - word.length] + word + out;
                } else {
                  out = word + out;
                }
                off += 2;
                if (off >= 26) {
                  off -= 26;
                  i--;
                }
              }
              if (carry !== 0) {
                out = carry.toString(16) + out;
              }
              while (out.length % padding !== 0) {
                out = "0" + out;
              }
              if (this.negative !== 0) {
                out = "-" + out;
              }
              return out;
            }
            if (base === (base | 0) && base >= 2 && base <= 36) {
              var groupSize = groupSizes[base];
              var groupBase = groupBases[base];
              out = "";
              var c = this.clone();
              c.negative = 0;
              while (!c.isZero()) {
                var r = c.modrn(groupBase).toString(base);
                c = c.idivn(groupBase);
                if (!c.isZero()) {
                  out = zeros[groupSize - r.length] + r + out;
                } else {
                  out = r + out;
                }
              }
              if (this.isZero()) {
                out = "0" + out;
              }
              while (out.length % padding !== 0) {
                out = "0" + out;
              }
              if (this.negative !== 0) {
                out = "-" + out;
              }
              return out;
            }
            assert(false, "Base should be between 2 and 36");
          };
          BN.prototype.toNumber = function toNumber() {
            var ret = this.words[0];
            if (this.length === 2) {
              ret += this.words[1] * 67108864;
            } else if (this.length === 3 && this.words[2] === 1) {
              ret += 4503599627370496 + this.words[1] * 67108864;
            } else if (this.length > 2) {
              assert(false, "Number can only safely store up to 53 bits");
            }
            return this.negative !== 0 ? -ret : ret;
          };
          BN.prototype.toJSON = function toJSON() {
            return this.toString(16, 2);
          };
          if (Buffer) {
            BN.prototype.toBuffer = function toBuffer(endian, length) {
              return this.toArrayLike(Buffer, endian, length);
            };
          }
          BN.prototype.toArray = function toArray(endian, length) {
            return this.toArrayLike(Array, endian, length);
          };
          var allocate = function allocate(ArrayType, size) {
            if (ArrayType.allocUnsafe) {
              return ArrayType.allocUnsafe(size);
            }
            return new ArrayType(size);
          };
          BN.prototype.toArrayLike = function toArrayLike(
            ArrayType,
            endian,
            length
          ) {
            this._strip();
            var byteLength = this.byteLength();
            var reqLength = length || Math.max(1, byteLength);
            assert(
              byteLength <= reqLength,
              "byte array longer than desired length"
            );
            assert(reqLength > 0, "Requested array length <= 0");
            var res = allocate(ArrayType, reqLength);
            var postfix = endian === "le" ? "LE" : "BE";
            this["_toArrayLike" + postfix](res, byteLength);
            return res;
          };
          BN.prototype._toArrayLikeLE = function _toArrayLikeLE(
            res,
            byteLength
          ) {
            var position = 0;
            var carry = 0;
            for (var i = 0, shift = 0; i < this.length; i++) {
              var word = (this.words[i] << shift) | carry;
              res[position++] = word & 255;
              if (position < res.length) {
                res[position++] = (word >> 8) & 255;
              }
              if (position < res.length) {
                res[position++] = (word >> 16) & 255;
              }
              if (shift === 6) {
                if (position < res.length) {
                  res[position++] = (word >> 24) & 255;
                }
                carry = 0;
                shift = 0;
              } else {
                carry = word >>> 24;
                shift += 2;
              }
            }
            if (position < res.length) {
              res[position++] = carry;
              while (position < res.length) {
                res[position++] = 0;
              }
            }
          };
          BN.prototype._toArrayLikeBE = function _toArrayLikeBE(
            res,
            byteLength
          ) {
            var position = res.length - 1;
            var carry = 0;
            for (var i = 0, shift = 0; i < this.length; i++) {
              var word = (this.words[i] << shift) | carry;
              res[position--] = word & 255;
              if (position >= 0) {
                res[position--] = (word >> 8) & 255;
              }
              if (position >= 0) {
                res[position--] = (word >> 16) & 255;
              }
              if (shift === 6) {
                if (position >= 0) {
                  res[position--] = (word >> 24) & 255;
                }
                carry = 0;
                shift = 0;
              } else {
                carry = word >>> 24;
                shift += 2;
              }
            }
            if (position >= 0) {
              res[position--] = carry;
              while (position >= 0) {
                res[position--] = 0;
              }
            }
          };
          if (Math.clz32) {
            BN.prototype._countBits = function _countBits(w) {
              return 32 - Math.clz32(w);
            };
          } else {
            BN.prototype._countBits = function _countBits(w) {
              var t = w;
              var r = 0;
              if (t >= 4096) {
                r += 13;
                t >>>= 13;
              }
              if (t >= 64) {
                r += 7;
                t >>>= 7;
              }
              if (t >= 8) {
                r += 4;
                t >>>= 4;
              }
              if (t >= 2) {
                r += 2;
                t >>>= 2;
              }
              return r + t;
            };
          }
          BN.prototype._zeroBits = function _zeroBits(w) {
            if (w === 0) return 26;
            var t = w;
            var r = 0;
            if ((t & 8191) === 0) {
              r += 13;
              t >>>= 13;
            }
            if ((t & 127) === 0) {
              r += 7;
              t >>>= 7;
            }
            if ((t & 15) === 0) {
              r += 4;
              t >>>= 4;
            }
            if ((t & 3) === 0) {
              r += 2;
              t >>>= 2;
            }
            if ((t & 1) === 0) {
              r++;
            }
            return r;
          };
          BN.prototype.bitLength = function bitLength() {
            var w = this.words[this.length - 1];
            var hi = this._countBits(w);
            return (this.length - 1) * 26 + hi;
          };
          function toBitArray(num) {
            var w = new Array(num.bitLength());
            for (var bit = 0; bit < w.length; bit++) {
              var off = (bit / 26) | 0;
              var wbit = bit % 26;
              w[bit] = (num.words[off] >>> wbit) & 1;
            }
            return w;
          }
          BN.prototype.zeroBits = function zeroBits() {
            if (this.isZero()) return 0;
            var r = 0;
            for (var i = 0; i < this.length; i++) {
              var b = this._zeroBits(this.words[i]);
              r += b;
              if (b !== 26) break;
            }
            return r;
          };
          BN.prototype.byteLength = function byteLength() {
            return Math.ceil(this.bitLength() / 8);
          };
          BN.prototype.toTwos = function toTwos(width) {
            if (this.negative !== 0) {
              return this.abs().inotn(width).iaddn(1);
            }
            return this.clone();
          };
          BN.prototype.fromTwos = function fromTwos(width) {
            if (this.testn(width - 1)) {
              return this.notn(width).iaddn(1).ineg();
            }
            return this.clone();
          };
          BN.prototype.isNeg = function isNeg() {
            return this.negative !== 0;
          };
          BN.prototype.neg = function neg() {
            return this.clone().ineg();
          };
          BN.prototype.ineg = function ineg() {
            if (!this.isZero()) {
              this.negative ^= 1;
            }
            return this;
          };
          BN.prototype.iuor = function iuor(num) {
            while (this.length < num.length) {
              this.words[this.length++] = 0;
            }
            for (var i = 0; i < num.length; i++) {
              this.words[i] = this.words[i] | num.words[i];
            }
            return this._strip();
          };
          BN.prototype.ior = function ior(num) {
            assert((this.negative | num.negative) === 0);
            return this.iuor(num);
          };
          BN.prototype.or = function or(num) {
            if (this.length > num.length) return this.clone().ior(num);
            return num.clone().ior(this);
          };
          BN.prototype.uor = function uor(num) {
            if (this.length > num.length) return this.clone().iuor(num);
            return num.clone().iuor(this);
          };
          BN.prototype.iuand = function iuand(num) {
            var b;
            if (this.length > num.length) {
              b = num;
            } else {
              b = this;
            }
            for (var i = 0; i < b.length; i++) {
              this.words[i] = this.words[i] & num.words[i];
            }
            this.length = b.length;
            return this._strip();
          };
          BN.prototype.iand = function iand(num) {
            assert((this.negative | num.negative) === 0);
            return this.iuand(num);
          };
          BN.prototype.and = function and(num) {
            if (this.length > num.length) return this.clone().iand(num);
            return num.clone().iand(this);
          };
          BN.prototype.uand = function uand(num) {
            if (this.length > num.length) return this.clone().iuand(num);
            return num.clone().iuand(this);
          };
          BN.prototype.iuxor = function iuxor(num) {
            var a;
            var b;
            if (this.length > num.length) {
              a = this;
              b = num;
            } else {
              a = num;
              b = this;
            }
            for (var i = 0; i < b.length; i++) {
              this.words[i] = a.words[i] ^ b.words[i];
            }
            if (this !== a) {
              for (; i < a.length; i++) {
                this.words[i] = a.words[i];
              }
            }
            this.length = a.length;
            return this._strip();
          };
          BN.prototype.ixor = function ixor(num) {
            assert((this.negative | num.negative) === 0);
            return this.iuxor(num);
          };
          BN.prototype.xor = function xor(num) {
            if (this.length > num.length) return this.clone().ixor(num);
            return num.clone().ixor(this);
          };
          BN.prototype.uxor = function uxor(num) {
            if (this.length > num.length) return this.clone().iuxor(num);
            return num.clone().iuxor(this);
          };
          BN.prototype.inotn = function inotn(width) {
            assert(typeof width === "number" && width >= 0);
            var bytesNeeded = Math.ceil(width / 26) | 0;
            var bitsLeft = width % 26;
            this._expand(bytesNeeded);
            if (bitsLeft > 0) {
              bytesNeeded--;
            }
            for (var i = 0; i < bytesNeeded; i++) {
              this.words[i] = ~this.words[i] & 67108863;
            }
            if (bitsLeft > 0) {
              this.words[i] = ~this.words[i] & (67108863 >> (26 - bitsLeft));
            }
            return this._strip();
          };
          BN.prototype.notn = function notn(width) {
            return this.clone().inotn(width);
          };
          BN.prototype.setn = function setn(bit, val) {
            assert(typeof bit === "number" && bit >= 0);
            var off = (bit / 26) | 0;
            var wbit = bit % 26;
            this._expand(off + 1);
            if (val) {
              this.words[off] = this.words[off] | (1 << wbit);
            } else {
              this.words[off] = this.words[off] & ~(1 << wbit);
            }
            return this._strip();
          };
          BN.prototype.iadd = function iadd(num) {
            var r;
            if (this.negative !== 0 && num.negative === 0) {
              this.negative = 0;
              r = this.isub(num);
              this.negative ^= 1;
              return this._normSign();
            } else if (this.negative === 0 && num.negative !== 0) {
              num.negative = 0;
              r = this.isub(num);
              num.negative = 1;
              return r._normSign();
            }
            var a, b;
            if (this.length > num.length) {
              a = this;
              b = num;
            } else {
              a = num;
              b = this;
            }
            var carry = 0;
            for (var i = 0; i < b.length; i++) {
              r = (a.words[i] | 0) + (b.words[i] | 0) + carry;
              this.words[i] = r & 67108863;
              carry = r >>> 26;
            }
            for (; carry !== 0 && i < a.length; i++) {
              r = (a.words[i] | 0) + carry;
              this.words[i] = r & 67108863;
              carry = r >>> 26;
            }
            this.length = a.length;
            if (carry !== 0) {
              this.words[this.length] = carry;
              this.length++;
            } else if (a !== this) {
              for (; i < a.length; i++) {
                this.words[i] = a.words[i];
              }
            }
            return this;
          };
          BN.prototype.add = function add(num) {
            var res;
            if (num.negative !== 0 && this.negative === 0) {
              num.negative = 0;
              res = this.sub(num);
              num.negative ^= 1;
              return res;
            } else if (num.negative === 0 && this.negative !== 0) {
              this.negative = 0;
              res = num.sub(this);
              this.negative = 1;
              return res;
            }
            if (this.length > num.length) return this.clone().iadd(num);
            return num.clone().iadd(this);
          };
          BN.prototype.isub = function isub(num) {
            if (num.negative !== 0) {
              num.negative = 0;
              var r = this.iadd(num);
              num.negative = 1;
              return r._normSign();
            } else if (this.negative !== 0) {
              this.negative = 0;
              this.iadd(num);
              this.negative = 1;
              return this._normSign();
            }
            var cmp = this.cmp(num);
            if (cmp === 0) {
              this.negative = 0;
              this.length = 1;
              this.words[0] = 0;
              return this;
            }
            var a, b;
            if (cmp > 0) {
              a = this;
              b = num;
            } else {
              a = num;
              b = this;
            }
            var carry = 0;
            for (var i = 0; i < b.length; i++) {
              r = (a.words[i] | 0) - (b.words[i] | 0) + carry;
              carry = r >> 26;
              this.words[i] = r & 67108863;
            }
            for (; carry !== 0 && i < a.length; i++) {
              r = (a.words[i] | 0) + carry;
              carry = r >> 26;
              this.words[i] = r & 67108863;
            }
            if (carry === 0 && i < a.length && a !== this) {
              for (; i < a.length; i++) {
                this.words[i] = a.words[i];
              }
            }
            this.length = Math.max(this.length, i);
            if (a !== this) {
              this.negative = 1;
            }
            return this._strip();
          };
          BN.prototype.sub = function sub(num) {
            return this.clone().isub(num);
          };
          function smallMulTo(self, num, out) {
            out.negative = num.negative ^ self.negative;
            var len = (self.length + num.length) | 0;
            out.length = len;
            len = (len - 1) | 0;
            var a = self.words[0] | 0;
            var b = num.words[0] | 0;
            var r = a * b;
            var lo = r & 67108863;
            var carry = (r / 67108864) | 0;
            out.words[0] = lo;
            for (var k = 1; k < len; k++) {
              var ncarry = carry >>> 26;
              var rword = carry & 67108863;
              var maxJ = Math.min(k, num.length - 1);
              for (var j = Math.max(0, k - self.length + 1); j <= maxJ; j++) {
                var i = (k - j) | 0;
                a = self.words[i] | 0;
                b = num.words[j] | 0;
                r = a * b + rword;
                ncarry += (r / 67108864) | 0;
                rword = r & 67108863;
              }
              out.words[k] = rword | 0;
              carry = ncarry | 0;
            }
            if (carry !== 0) {
              out.words[k] = carry | 0;
            } else {
              out.length--;
            }
            return out._strip();
          }
          var comb10MulTo = function comb10MulTo(self, num, out) {
            var a = self.words;
            var b = num.words;
            var o = out.words;
            var c = 0;
            var lo;
            var mid;
            var hi;
            var a0 = a[0] | 0;
            var al0 = a0 & 8191;
            var ah0 = a0 >>> 13;
            var a1 = a[1] | 0;
            var al1 = a1 & 8191;
            var ah1 = a1 >>> 13;
            var a2 = a[2] | 0;
            var al2 = a2 & 8191;
            var ah2 = a2 >>> 13;
            var a3 = a[3] | 0;
            var al3 = a3 & 8191;
            var ah3 = a3 >>> 13;
            var a4 = a[4] | 0;
            var al4 = a4 & 8191;
            var ah4 = a4 >>> 13;
            var a5 = a[5] | 0;
            var al5 = a5 & 8191;
            var ah5 = a5 >>> 13;
            var a6 = a[6] | 0;
            var al6 = a6 & 8191;
            var ah6 = a6 >>> 13;
            var a7 = a[7] | 0;
            var al7 = a7 & 8191;
            var ah7 = a7 >>> 13;
            var a8 = a[8] | 0;
            var al8 = a8 & 8191;
            var ah8 = a8 >>> 13;
            var a9 = a[9] | 0;
            var al9 = a9 & 8191;
            var ah9 = a9 >>> 13;
            var b0 = b[0] | 0;
            var bl0 = b0 & 8191;
            var bh0 = b0 >>> 13;
            var b1 = b[1] | 0;
            var bl1 = b1 & 8191;
            var bh1 = b1 >>> 13;
            var b2 = b[2] | 0;
            var bl2 = b2 & 8191;
            var bh2 = b2 >>> 13;
            var b3 = b[3] | 0;
            var bl3 = b3 & 8191;
            var bh3 = b3 >>> 13;
            var b4 = b[4] | 0;
            var bl4 = b4 & 8191;
            var bh4 = b4 >>> 13;
            var b5 = b[5] | 0;
            var bl5 = b5 & 8191;
            var bh5 = b5 >>> 13;
            var b6 = b[6] | 0;
            var bl6 = b6 & 8191;
            var bh6 = b6 >>> 13;
            var b7 = b[7] | 0;
            var bl7 = b7 & 8191;
            var bh7 = b7 >>> 13;
            var b8 = b[8] | 0;
            var bl8 = b8 & 8191;
            var bh8 = b8 >>> 13;
            var b9 = b[9] | 0;
            var bl9 = b9 & 8191;
            var bh9 = b9 >>> 13;
            out.negative = self.negative ^ num.negative;
            out.length = 19;
            lo = Math.imul(al0, bl0);
            mid = Math.imul(al0, bh0);
            mid = (mid + Math.imul(ah0, bl0)) | 0;
            hi = Math.imul(ah0, bh0);
            var w0 = (((c + lo) | 0) + ((mid & 8191) << 13)) | 0;
            c = (((hi + (mid >>> 13)) | 0) + (w0 >>> 26)) | 0;
            w0 &= 67108863;
            lo = Math.imul(al1, bl0);
            mid = Math.imul(al1, bh0);
            mid = (mid + Math.imul(ah1, bl0)) | 0;
            hi = Math.imul(ah1, bh0);
            lo = (lo + Math.imul(al0, bl1)) | 0;
            mid = (mid + Math.imul(al0, bh1)) | 0;
            mid = (mid + Math.imul(ah0, bl1)) | 0;
            hi = (hi + Math.imul(ah0, bh1)) | 0;
            var w1 = (((c + lo) | 0) + ((mid & 8191) << 13)) | 0;
            c = (((hi + (mid >>> 13)) | 0) + (w1 >>> 26)) | 0;
            w1 &= 67108863;
            lo = Math.imul(al2, bl0);
            mid = Math.imul(al2, bh0);
            mid = (mid + Math.imul(ah2, bl0)) | 0;
            hi = Math.imul(ah2, bh0);
            lo = (lo + Math.imul(al1, bl1)) | 0;
            mid = (mid + Math.imul(al1, bh1)) | 0;
            mid = (mid + Math.imul(ah1, bl1)) | 0;
            hi = (hi + Math.imul(ah1, bh1)) | 0;
            lo = (lo + Math.imul(al0, bl2)) | 0;
            mid = (mid + Math.imul(al0, bh2)) | 0;
            mid = (mid + Math.imul(ah0, bl2)) | 0;
            hi = (hi + Math.imul(ah0, bh2)) | 0;
            var w2 = (((c + lo) | 0) + ((mid & 8191) << 13)) | 0;
            c = (((hi + (mid >>> 13)) | 0) + (w2 >>> 26)) | 0;
            w2 &= 67108863;
            lo = Math.imul(al3, bl0);
            mid = Math.imul(al3, bh0);
            mid = (mid + Math.imul(ah3, bl0)) | 0;
            hi = Math.imul(ah3, bh0);
            lo = (lo + Math.imul(al2, bl1)) | 0;
            mid = (mid + Math.imul(al2, bh1)) | 0;
            mid = (mid + Math.imul(ah2, bl1)) | 0;
            hi = (hi + Math.imul(ah2, bh1)) | 0;
            lo = (lo + Math.imul(al1, bl2)) | 0;
            mid = (mid + Math.imul(al1, bh2)) | 0;
            mid = (mid + Math.imul(ah1, bl2)) | 0;
            hi = (hi + Math.imul(ah1, bh2)) | 0;
            lo = (lo + Math.imul(al0, bl3)) | 0;
            mid = (mid + Math.imul(al0, bh3)) | 0;
            mid = (mid + Math.imul(ah0, bl3)) | 0;
            hi = (hi + Math.imul(ah0, bh3)) | 0;
            var w3 = (((c + lo) | 0) + ((mid & 8191) << 13)) | 0;
            c = (((hi + (mid >>> 13)) | 0) + (w3 >>> 26)) | 0;
            w3 &= 67108863;
            lo = Math.imul(al4, bl0);
            mid = Math.imul(al4, bh0);
            mid = (mid + Math.imul(ah4, bl0)) | 0;
            hi = Math.imul(ah4, bh0);
            lo = (lo + Math.imul(al3, bl1)) | 0;
            mid = (mid + Math.imul(al3, bh1)) | 0;
            mid = (mid + Math.imul(ah3, bl1)) | 0;
            hi = (hi + Math.imul(ah3, bh1)) | 0;
            lo = (lo + Math.imul(al2, bl2)) | 0;
            mid = (mid + Math.imul(al2, bh2)) | 0;
            mid = (mid + Math.imul(ah2, bl2)) | 0;
            hi = (hi + Math.imul(ah2, bh2)) | 0;
            lo = (lo + Math.imul(al1, bl3)) | 0;
            mid = (mid + Math.imul(al1, bh3)) | 0;
            mid = (mid + Math.imul(ah1, bl3)) | 0;
            hi = (hi + Math.imul(ah1, bh3)) | 0;
            lo = (lo + Math.imul(al0, bl4)) | 0;
            mid = (mid + Math.imul(al0, bh4)) | 0;
            mid = (mid + Math.imul(ah0, bl4)) | 0;
            hi = (hi + Math.imul(ah0, bh4)) | 0;
            var w4 = (((c + lo) | 0) + ((mid & 8191) << 13)) | 0;
            c = (((hi + (mid >>> 13)) | 0) + (w4 >>> 26)) | 0;
            w4 &= 67108863;
            lo = Math.imul(al5, bl0);
            mid = Math.imul(al5, bh0);
            mid = (mid + Math.imul(ah5, bl0)) | 0;
            hi = Math.imul(ah5, bh0);
            lo = (lo + Math.imul(al4, bl1)) | 0;
            mid = (mid + Math.imul(al4, bh1)) | 0;
            mid = (mid + Math.imul(ah4, bl1)) | 0;
            hi = (hi + Math.imul(ah4, bh1)) | 0;
            lo = (lo + Math.imul(al3, bl2)) | 0;
            mid = (mid + Math.imul(al3, bh2)) | 0;
            mid = (mid + Math.imul(ah3, bl2)) | 0;
            hi = (hi + Math.imul(ah3, bh2)) | 0;
            lo = (lo + Math.imul(al2, bl3)) | 0;
            mid = (mid + Math.imul(al2, bh3)) | 0;
            mid = (mid + Math.imul(ah2, bl3)) | 0;
            hi = (hi + Math.imul(ah2, bh3)) | 0;
            lo = (lo + Math.imul(al1, bl4)) | 0;
            mid = (mid + Math.imul(al1, bh4)) | 0;
            mid = (mid + Math.imul(ah1, bl4)) | 0;
            hi = (hi + Math.imul(ah1, bh4)) | 0;
            lo = (lo + Math.imul(al0, bl5)) | 0;
            mid = (mid + Math.imul(al0, bh5)) | 0;
            mid = (mid + Math.imul(ah0, bl5)) | 0;
            hi = (hi + Math.imul(ah0, bh5)) | 0;
            var w5 = (((c + lo) | 0) + ((mid & 8191) << 13)) | 0;
            c = (((hi + (mid >>> 13)) | 0) + (w5 >>> 26)) | 0;
            w5 &= 67108863;
            lo = Math.imul(al6, bl0);
            mid = Math.imul(al6, bh0);
            mid = (mid + Math.imul(ah6, bl0)) | 0;
            hi = Math.imul(ah6, bh0);
            lo = (lo + Math.imul(al5, bl1)) | 0;
            mid = (mid + Math.imul(al5, bh1)) | 0;
            mid = (mid + Math.imul(ah5, bl1)) | 0;
            hi = (hi + Math.imul(ah5, bh1)) | 0;
            lo = (lo + Math.imul(al4, bl2)) | 0;
            mid = (mid + Math.imul(al4, bh2)) | 0;
            mid = (mid + Math.imul(ah4, bl2)) | 0;
            hi = (hi + Math.imul(ah4, bh2)) | 0;
            lo = (lo + Math.imul(al3, bl3)) | 0;
            mid = (mid + Math.imul(al3, bh3)) | 0;
            mid = (mid + Math.imul(ah3, bl3)) | 0;
            hi = (hi + Math.imul(ah3, bh3)) | 0;
            lo = (lo + Math.imul(al2, bl4)) | 0;
            mid = (mid + Math.imul(al2, bh4)) | 0;
            mid = (mid + Math.imul(ah2, bl4)) | 0;
            hi = (hi + Math.imul(ah2, bh4)) | 0;
            lo = (lo + Math.imul(al1, bl5)) | 0;
            mid = (mid + Math.imul(al1, bh5)) | 0;
            mid = (mid + Math.imul(ah1, bl5)) | 0;
            hi = (hi + Math.imul(ah1, bh5)) | 0;
            lo = (lo + Math.imul(al0, bl6)) | 0;
            mid = (mid + Math.imul(al0, bh6)) | 0;
            mid = (mid + Math.imul(ah0, bl6)) | 0;
            hi = (hi + Math.imul(ah0, bh6)) | 0;
            var w6 = (((c + lo) | 0) + ((mid & 8191) << 13)) | 0;
            c = (((hi + (mid >>> 13)) | 0) + (w6 >>> 26)) | 0;
            w6 &= 67108863;
            lo = Math.imul(al7, bl0);
            mid = Math.imul(al7, bh0);
            mid = (mid + Math.imul(ah7, bl0)) | 0;
            hi = Math.imul(ah7, bh0);
            lo = (lo + Math.imul(al6, bl1)) | 0;
            mid = (mid + Math.imul(al6, bh1)) | 0;
            mid = (mid + Math.imul(ah6, bl1)) | 0;
            hi = (hi + Math.imul(ah6, bh1)) | 0;
            lo = (lo + Math.imul(al5, bl2)) | 0;
            mid = (mid + Math.imul(al5, bh2)) | 0;
            mid = (mid + Math.imul(ah5, bl2)) | 0;
            hi = (hi + Math.imul(ah5, bh2)) | 0;
            lo = (lo + Math.imul(al4, bl3)) | 0;
            mid = (mid + Math.imul(al4, bh3)) | 0;
            mid = (mid + Math.imul(ah4, bl3)) | 0;
            hi = (hi + Math.imul(ah4, bh3)) | 0;
            lo = (lo + Math.imul(al3, bl4)) | 0;
            mid = (mid + Math.imul(al3, bh4)) | 0;
            mid = (mid + Math.imul(ah3, bl4)) | 0;
            hi = (hi + Math.imul(ah3, bh4)) | 0;
            lo = (lo + Math.imul(al2, bl5)) | 0;
            mid = (mid + Math.imul(al2, bh5)) | 0;
            mid = (mid + Math.imul(ah2, bl5)) | 0;
            hi = (hi + Math.imul(ah2, bh5)) | 0;
            lo = (lo + Math.imul(al1, bl6)) | 0;
            mid = (mid + Math.imul(al1, bh6)) | 0;
            mid = (mid + Math.imul(ah1, bl6)) | 0;
            hi = (hi + Math.imul(ah1, bh6)) | 0;
            lo = (lo + Math.imul(al0, bl7)) | 0;
            mid = (mid + Math.imul(al0, bh7)) | 0;
            mid = (mid + Math.imul(ah0, bl7)) | 0;
            hi = (hi + Math.imul(ah0, bh7)) | 0;
            var w7 = (((c + lo) | 0) + ((mid & 8191) << 13)) | 0;
            c = (((hi + (mid >>> 13)) | 0) + (w7 >>> 26)) | 0;
            w7 &= 67108863;
            lo = Math.imul(al8, bl0);
            mid = Math.imul(al8, bh0);
            mid = (mid + Math.imul(ah8, bl0)) | 0;
            hi = Math.imul(ah8, bh0);
            lo = (lo + Math.imul(al7, bl1)) | 0;
            mid = (mid + Math.imul(al7, bh1)) | 0;
            mid = (mid + Math.imul(ah7, bl1)) | 0;
            hi = (hi + Math.imul(ah7, bh1)) | 0;
            lo = (lo + Math.imul(al6, bl2)) | 0;
            mid = (mid + Math.imul(al6, bh2)) | 0;
            mid = (mid + Math.imul(ah6, bl2)) | 0;
            hi = (hi + Math.imul(ah6, bh2)) | 0;
            lo = (lo + Math.imul(al5, bl3)) | 0;
            mid = (mid + Math.imul(al5, bh3)) | 0;
            mid = (mid + Math.imul(ah5, bl3)) | 0;
            hi = (hi + Math.imul(ah5, bh3)) | 0;
            lo = (lo + Math.imul(al4, bl4)) | 0;
            mid = (mid + Math.imul(al4, bh4)) | 0;
            mid = (mid + Math.imul(ah4, bl4)) | 0;
            hi = (hi + Math.imul(ah4, bh4)) | 0;
            lo = (lo + Math.imul(al3, bl5)) | 0;
            mid = (mid + Math.imul(al3, bh5)) | 0;
            mid = (mid + Math.imul(ah3, bl5)) | 0;
            hi = (hi + Math.imul(ah3, bh5)) | 0;
            lo = (lo + Math.imul(al2, bl6)) | 0;
            mid = (mid + Math.imul(al2, bh6)) | 0;
            mid = (mid + Math.imul(ah2, bl6)) | 0;
            hi = (hi + Math.imul(ah2, bh6)) | 0;
            lo = (lo + Math.imul(al1, bl7)) | 0;
            mid = (mid + Math.imul(al1, bh7)) | 0;
            mid = (mid + Math.imul(ah1, bl7)) | 0;
            hi = (hi + Math.imul(ah1, bh7)) | 0;
            lo = (lo + Math.imul(al0, bl8)) | 0;
            mid = (mid + Math.imul(al0, bh8)) | 0;
            mid = (mid + Math.imul(ah0, bl8)) | 0;
            hi = (hi + Math.imul(ah0, bh8)) | 0;
            var w8 = (((c + lo) | 0) + ((mid & 8191) << 13)) | 0;
            c = (((hi + (mid >>> 13)) | 0) + (w8 >>> 26)) | 0;
            w8 &= 67108863;
            lo = Math.imul(al9, bl0);
            mid = Math.imul(al9, bh0);
            mid = (mid + Math.imul(ah9, bl0)) | 0;
            hi = Math.imul(ah9, bh0);
            lo = (lo + Math.imul(al8, bl1)) | 0;
            mid = (mid + Math.imul(al8, bh1)) | 0;
            mid = (mid + Math.imul(ah8, bl1)) | 0;
            hi = (hi + Math.imul(ah8, bh1)) | 0;
            lo = (lo + Math.imul(al7, bl2)) | 0;
            mid = (mid + Math.imul(al7, bh2)) | 0;
            mid = (mid + Math.imul(ah7, bl2)) | 0;
            hi = (hi + Math.imul(ah7, bh2)) | 0;
            lo = (lo + Math.imul(al6, bl3)) | 0;
            mid = (mid + Math.imul(al6, bh3)) | 0;
            mid = (mid + Math.imul(ah6, bl3)) | 0;
            hi = (hi + Math.imul(ah6, bh3)) | 0;
            lo = (lo + Math.imul(al5, bl4)) | 0;
            mid = (mid + Math.imul(al5, bh4)) | 0;
            mid = (mid + Math.imul(ah5, bl4)) | 0;
            hi = (hi + Math.imul(ah5, bh4)) | 0;
            lo = (lo + Math.imul(al4, bl5)) | 0;
            mid = (mid + Math.imul(al4, bh5)) | 0;
            mid = (mid + Math.imul(ah4, bl5)) | 0;
            hi = (hi + Math.imul(ah4, bh5)) | 0;
            lo = (lo + Math.imul(al3, bl6)) | 0;
            mid = (mid + Math.imul(al3, bh6)) | 0;
            mid = (mid + Math.imul(ah3, bl6)) | 0;
            hi = (hi + Math.imul(ah3, bh6)) | 0;
            lo = (lo + Math.imul(al2, bl7)) | 0;
            mid = (mid + Math.imul(al2, bh7)) | 0;
            mid = (mid + Math.imul(ah2, bl7)) | 0;
            hi = (hi + Math.imul(ah2, bh7)) | 0;
            lo = (lo + Math.imul(al1, bl8)) | 0;
            mid = (mid + Math.imul(al1, bh8)) | 0;
            mid = (mid + Math.imul(ah1, bl8)) | 0;
            hi = (hi + Math.imul(ah1, bh8)) | 0;
            lo = (lo + Math.imul(al0, bl9)) | 0;
            mid = (mid + Math.imul(al0, bh9)) | 0;
            mid = (mid + Math.imul(ah0, bl9)) | 0;
            hi = (hi + Math.imul(ah0, bh9)) | 0;
            var w9 = (((c + lo) | 0) + ((mid & 8191) << 13)) | 0;
            c = (((hi + (mid >>> 13)) | 0) + (w9 >>> 26)) | 0;
            w9 &= 67108863;
            lo = Math.imul(al9, bl1);
            mid = Math.imul(al9, bh1);
            mid = (mid + Math.imul(ah9, bl1)) | 0;
            hi = Math.imul(ah9, bh1);
            lo = (lo + Math.imul(al8, bl2)) | 0;
            mid = (mid + Math.imul(al8, bh2)) | 0;
            mid = (mid + Math.imul(ah8, bl2)) | 0;
            hi = (hi + Math.imul(ah8, bh2)) | 0;
            lo = (lo + Math.imul(al7, bl3)) | 0;
            mid = (mid + Math.imul(al7, bh3)) | 0;
            mid = (mid + Math.imul(ah7, bl3)) | 0;
            hi = (hi + Math.imul(ah7, bh3)) | 0;
            lo = (lo + Math.imul(al6, bl4)) | 0;
            mid = (mid + Math.imul(al6, bh4)) | 0;
            mid = (mid + Math.imul(ah6, bl4)) | 0;
            hi = (hi + Math.imul(ah6, bh4)) | 0;
            lo = (lo + Math.imul(al5, bl5)) | 0;
            mid = (mid + Math.imul(al5, bh5)) | 0;
            mid = (mid + Math.imul(ah5, bl5)) | 0;
            hi = (hi + Math.imul(ah5, bh5)) | 0;
            lo = (lo + Math.imul(al4, bl6)) | 0;
            mid = (mid + Math.imul(al4, bh6)) | 0;
            mid = (mid + Math.imul(ah4, bl6)) | 0;
            hi = (hi + Math.imul(ah4, bh6)) | 0;
            lo = (lo + Math.imul(al3, bl7)) | 0;
            mid = (mid + Math.imul(al3, bh7)) | 0;
            mid = (mid + Math.imul(ah3, bl7)) | 0;
            hi = (hi + Math.imul(ah3, bh7)) | 0;
            lo = (lo + Math.imul(al2, bl8)) | 0;
            mid = (mid + Math.imul(al2, bh8)) | 0;
            mid = (mid + Math.imul(ah2, bl8)) | 0;
            hi = (hi + Math.imul(ah2, bh8)) | 0;
            lo = (lo + Math.imul(al1, bl9)) | 0;
            mid = (mid + Math.imul(al1, bh9)) | 0;
            mid = (mid + Math.imul(ah1, bl9)) | 0;
            hi = (hi + Math.imul(ah1, bh9)) | 0;
            var w10 = (((c + lo) | 0) + ((mid & 8191) << 13)) | 0;
            c = (((hi + (mid >>> 13)) | 0) + (w10 >>> 26)) | 0;
            w10 &= 67108863;
            lo = Math.imul(al9, bl2);
            mid = Math.imul(al9, bh2);
            mid = (mid + Math.imul(ah9, bl2)) | 0;
            hi = Math.imul(ah9, bh2);
            lo = (lo + Math.imul(al8, bl3)) | 0;
            mid = (mid + Math.imul(al8, bh3)) | 0;
            mid = (mid + Math.imul(ah8, bl3)) | 0;
            hi = (hi + Math.imul(ah8, bh3)) | 0;
            lo = (lo + Math.imul(al7, bl4)) | 0;
            mid = (mid + Math.imul(al7, bh4)) | 0;
            mid = (mid + Math.imul(ah7, bl4)) | 0;
            hi = (hi + Math.imul(ah7, bh4)) | 0;
            lo = (lo + Math.imul(al6, bl5)) | 0;
            mid = (mid + Math.imul(al6, bh5)) | 0;
            mid = (mid + Math.imul(ah6, bl5)) | 0;
            hi = (hi + Math.imul(ah6, bh5)) | 0;
            lo = (lo + Math.imul(al5, bl6)) | 0;
            mid = (mid + Math.imul(al5, bh6)) | 0;
            mid = (mid + Math.imul(ah5, bl6)) | 0;
            hi = (hi + Math.imul(ah5, bh6)) | 0;
            lo = (lo + Math.imul(al4, bl7)) | 0;
            mid = (mid + Math.imul(al4, bh7)) | 0;
            mid = (mid + Math.imul(ah4, bl7)) | 0;
            hi = (hi + Math.imul(ah4, bh7)) | 0;
            lo = (lo + Math.imul(al3, bl8)) | 0;
            mid = (mid + Math.imul(al3, bh8)) | 0;
            mid = (mid + Math.imul(ah3, bl8)) | 0;
            hi = (hi + Math.imul(ah3, bh8)) | 0;
            lo = (lo + Math.imul(al2, bl9)) | 0;
            mid = (mid + Math.imul(al2, bh9)) | 0;
            mid = (mid + Math.imul(ah2, bl9)) | 0;
            hi = (hi + Math.imul(ah2, bh9)) | 0;
            var w11 = (((c + lo) | 0) + ((mid & 8191) << 13)) | 0;
            c = (((hi + (mid >>> 13)) | 0) + (w11 >>> 26)) | 0;
            w11 &= 67108863;
            lo = Math.imul(al9, bl3);
            mid = Math.imul(al9, bh3);
            mid = (mid + Math.imul(ah9, bl3)) | 0;
            hi = Math.imul(ah9, bh3);
            lo = (lo + Math.imul(al8, bl4)) | 0;
            mid = (mid + Math.imul(al8, bh4)) | 0;
            mid = (mid + Math.imul(ah8, bl4)) | 0;
            hi = (hi + Math.imul(ah8, bh4)) | 0;
            lo = (lo + Math.imul(al7, bl5)) | 0;
            mid = (mid + Math.imul(al7, bh5)) | 0;
            mid = (mid + Math.imul(ah7, bl5)) | 0;
            hi = (hi + Math.imul(ah7, bh5)) | 0;
            lo = (lo + Math.imul(al6, bl6)) | 0;
            mid = (mid + Math.imul(al6, bh6)) | 0;
            mid = (mid + Math.imul(ah6, bl6)) | 0;
            hi = (hi + Math.imul(ah6, bh6)) | 0;
            lo = (lo + Math.imul(al5, bl7)) | 0;
            mid = (mid + Math.imul(al5, bh7)) | 0;
            mid = (mid + Math.imul(ah5, bl7)) | 0;
            hi = (hi + Math.imul(ah5, bh7)) | 0;
            lo = (lo + Math.imul(al4, bl8)) | 0;
            mid = (mid + Math.imul(al4, bh8)) | 0;
            mid = (mid + Math.imul(ah4, bl8)) | 0;
            hi = (hi + Math.imul(ah4, bh8)) | 0;
            lo = (lo + Math.imul(al3, bl9)) | 0;
            mid = (mid + Math.imul(al3, bh9)) | 0;
            mid = (mid + Math.imul(ah3, bl9)) | 0;
            hi = (hi + Math.imul(ah3, bh9)) | 0;
            var w12 = (((c + lo) | 0) + ((mid & 8191) << 13)) | 0;
            c = (((hi + (mid >>> 13)) | 0) + (w12 >>> 26)) | 0;
            w12 &= 67108863;
            lo = Math.imul(al9, bl4);
            mid = Math.imul(al9, bh4);
            mid = (mid + Math.imul(ah9, bl4)) | 0;
            hi = Math.imul(ah9, bh4);
            lo = (lo + Math.imul(al8, bl5)) | 0;
            mid = (mid + Math.imul(al8, bh5)) | 0;
            mid = (mid + Math.imul(ah8, bl5)) | 0;
            hi = (hi + Math.imul(ah8, bh5)) | 0;
            lo = (lo + Math.imul(al7, bl6)) | 0;
            mid = (mid + Math.imul(al7, bh6)) | 0;
            mid = (mid + Math.imul(ah7, bl6)) | 0;
            hi = (hi + Math.imul(ah7, bh6)) | 0;
            lo = (lo + Math.imul(al6, bl7)) | 0;
            mid = (mid + Math.imul(al6, bh7)) | 0;
            mid = (mid + Math.imul(ah6, bl7)) | 0;
            hi = (hi + Math.imul(ah6, bh7)) | 0;
            lo = (lo + Math.imul(al5, bl8)) | 0;
            mid = (mid + Math.imul(al5, bh8)) | 0;
            mid = (mid + Math.imul(ah5, bl8)) | 0;
            hi = (hi + Math.imul(ah5, bh8)) | 0;
            lo = (lo + Math.imul(al4, bl9)) | 0;
            mid = (mid + Math.imul(al4, bh9)) | 0;
            mid = (mid + Math.imul(ah4, bl9)) | 0;
            hi = (hi + Math.imul(ah4, bh9)) | 0;
            var w13 = (((c + lo) | 0) + ((mid & 8191) << 13)) | 0;
            c = (((hi + (mid >>> 13)) | 0) + (w13 >>> 26)) | 0;
            w13 &= 67108863;
            lo = Math.imul(al9, bl5);
            mid = Math.imul(al9, bh5);
            mid = (mid + Math.imul(ah9, bl5)) | 0;
            hi = Math.imul(ah9, bh5);
            lo = (lo + Math.imul(al8, bl6)) | 0;
            mid = (mid + Math.imul(al8, bh6)) | 0;
            mid = (mid + Math.imul(ah8, bl6)) | 0;
            hi = (hi + Math.imul(ah8, bh6)) | 0;
            lo = (lo + Math.imul(al7, bl7)) | 0;
            mid = (mid + Math.imul(al7, bh7)) | 0;
            mid = (mid + Math.imul(ah7, bl7)) | 0;
            hi = (hi + Math.imul(ah7, bh7)) | 0;
            lo = (lo + Math.imul(al6, bl8)) | 0;
            mid = (mid + Math.imul(al6, bh8)) | 0;
            mid = (mid + Math.imul(ah6, bl8)) | 0;
            hi = (hi + Math.imul(ah6, bh8)) | 0;
            lo = (lo + Math.imul(al5, bl9)) | 0;
            mid = (mid + Math.imul(al5, bh9)) | 0;
            mid = (mid + Math.imul(ah5, bl9)) | 0;
            hi = (hi + Math.imul(ah5, bh9)) | 0;
            var w14 = (((c + lo) | 0) + ((mid & 8191) << 13)) | 0;
            c = (((hi + (mid >>> 13)) | 0) + (w14 >>> 26)) | 0;
            w14 &= 67108863;
            lo = Math.imul(al9, bl6);
            mid = Math.imul(al9, bh6);
            mid = (mid + Math.imul(ah9, bl6)) | 0;
            hi = Math.imul(ah9, bh6);
            lo = (lo + Math.imul(al8, bl7)) | 0;
            mid = (mid + Math.imul(al8, bh7)) | 0;
            mid = (mid + Math.imul(ah8, bl7)) | 0;
            hi = (hi + Math.imul(ah8, bh7)) | 0;
            lo = (lo + Math.imul(al7, bl8)) | 0;
            mid = (mid + Math.imul(al7, bh8)) | 0;
            mid = (mid + Math.imul(ah7, bl8)) | 0;
            hi = (hi + Math.imul(ah7, bh8)) | 0;
            lo = (lo + Math.imul(al6, bl9)) | 0;
            mid = (mid + Math.imul(al6, bh9)) | 0;
            mid = (mid + Math.imul(ah6, bl9)) | 0;
            hi = (hi + Math.imul(ah6, bh9)) | 0;
            var w15 = (((c + lo) | 0) + ((mid & 8191) << 13)) | 0;
            c = (((hi + (mid >>> 13)) | 0) + (w15 >>> 26)) | 0;
            w15 &= 67108863;
            lo = Math.imul(al9, bl7);
            mid = Math.imul(al9, bh7);
            mid = (mid + Math.imul(ah9, bl7)) | 0;
            hi = Math.imul(ah9, bh7);
            lo = (lo + Math.imul(al8, bl8)) | 0;
            mid = (mid + Math.imul(al8, bh8)) | 0;
            mid = (mid + Math.imul(ah8, bl8)) | 0;
            hi = (hi + Math.imul(ah8, bh8)) | 0;
            lo = (lo + Math.imul(al7, bl9)) | 0;
            mid = (mid + Math.imul(al7, bh9)) | 0;
            mid = (mid + Math.imul(ah7, bl9)) | 0;
            hi = (hi + Math.imul(ah7, bh9)) | 0;
            var w16 = (((c + lo) | 0) + ((mid & 8191) << 13)) | 0;
            c = (((hi + (mid >>> 13)) | 0) + (w16 >>> 26)) | 0;
            w16 &= 67108863;
            lo = Math.imul(al9, bl8);
            mid = Math.imul(al9, bh8);
            mid = (mid + Math.imul(ah9, bl8)) | 0;
            hi = Math.imul(ah9, bh8);
            lo = (lo + Math.imul(al8, bl9)) | 0;
            mid = (mid + Math.imul(al8, bh9)) | 0;
            mid = (mid + Math.imul(ah8, bl9)) | 0;
            hi = (hi + Math.imul(ah8, bh9)) | 0;
            var w17 = (((c + lo) | 0) + ((mid & 8191) << 13)) | 0;
            c = (((hi + (mid >>> 13)) | 0) + (w17 >>> 26)) | 0;
            w17 &= 67108863;
            lo = Math.imul(al9, bl9);
            mid = Math.imul(al9, bh9);
            mid = (mid + Math.imul(ah9, bl9)) | 0;
            hi = Math.imul(ah9, bh9);
            var w18 = (((c + lo) | 0) + ((mid & 8191) << 13)) | 0;
            c = (((hi + (mid >>> 13)) | 0) + (w18 >>> 26)) | 0;
            w18 &= 67108863;
            o[0] = w0;
            o[1] = w1;
            o[2] = w2;
            o[3] = w3;
            o[4] = w4;
            o[5] = w5;
            o[6] = w6;
            o[7] = w7;
            o[8] = w8;
            o[9] = w9;
            o[10] = w10;
            o[11] = w11;
            o[12] = w12;
            o[13] = w13;
            o[14] = w14;
            o[15] = w15;
            o[16] = w16;
            o[17] = w17;
            o[18] = w18;
            if (c !== 0) {
              o[19] = c;
              out.length++;
            }
            return out;
          };
          if (!Math.imul) {
            comb10MulTo = smallMulTo;
          }
          function bigMulTo(self, num, out) {
            out.negative = num.negative ^ self.negative;
            out.length = self.length + num.length;
            var carry = 0;
            var hncarry = 0;
            for (var k = 0; k < out.length - 1; k++) {
              var ncarry = hncarry;
              hncarry = 0;
              var rword = carry & 67108863;
              var maxJ = Math.min(k, num.length - 1);
              for (var j = Math.max(0, k - self.length + 1); j <= maxJ; j++) {
                var i = k - j;
                var a = self.words[i] | 0;
                var b = num.words[j] | 0;
                var r = a * b;
                var lo = r & 67108863;
                ncarry = (ncarry + ((r / 67108864) | 0)) | 0;
                lo = (lo + rword) | 0;
                rword = lo & 67108863;
                ncarry = (ncarry + (lo >>> 26)) | 0;
                hncarry += ncarry >>> 26;
                ncarry &= 67108863;
              }
              out.words[k] = rword;
              carry = ncarry;
              ncarry = hncarry;
            }
            if (carry !== 0) {
              out.words[k] = carry;
            } else {
              out.length--;
            }
            return out._strip();
          }
          function jumboMulTo(self, num, out) {
            return bigMulTo(self, num, out);
          }
          BN.prototype.mulTo = function mulTo(num, out) {
            var res;
            var len = this.length + num.length;
            if (this.length === 10 && num.length === 10) {
              res = comb10MulTo(this, num, out);
            } else if (len < 63) {
              res = smallMulTo(this, num, out);
            } else if (len < 1024) {
              res = bigMulTo(this, num, out);
            } else {
              res = jumboMulTo(this, num, out);
            }
            return res;
          };
          function FFTM(x, y) {
            this.x = x;
            this.y = y;
          }
          FFTM.prototype.makeRBT = function makeRBT(N) {
            var t = new Array(N);
            var l = BN.prototype._countBits(N) - 1;
            for (var i = 0; i < N; i++) {
              t[i] = this.revBin(i, l, N);
            }
            return t;
          };
          FFTM.prototype.revBin = function revBin(x, l, N) {
            if (x === 0 || x === N - 1) return x;
            var rb = 0;
            for (var i = 0; i < l; i++) {
              rb |= (x & 1) << (l - i - 1);
              x >>= 1;
            }
            return rb;
          };
          FFTM.prototype.permute = function permute(
            rbt,
            rws,
            iws,
            rtws,
            itws,
            N
          ) {
            for (var i = 0; i < N; i++) {
              rtws[i] = rws[rbt[i]];
              itws[i] = iws[rbt[i]];
            }
          };
          FFTM.prototype.transform = function transform(
            rws,
            iws,
            rtws,
            itws,
            N,
            rbt
          ) {
            this.permute(rbt, rws, iws, rtws, itws, N);
            for (var s = 1; s < N; s <<= 1) {
              var l = s << 1;
              var rtwdf = Math.cos((2 * Math.PI) / l);
              var itwdf = Math.sin((2 * Math.PI) / l);
              for (var p = 0; p < N; p += l) {
                var rtwdf_ = rtwdf;
                var itwdf_ = itwdf;
                for (var j = 0; j < s; j++) {
                  var re = rtws[p + j];
                  var ie = itws[p + j];
                  var ro = rtws[p + j + s];
                  var io = itws[p + j + s];
                  var rx = rtwdf_ * ro - itwdf_ * io;
                  io = rtwdf_ * io + itwdf_ * ro;
                  ro = rx;
                  rtws[p + j] = re + ro;
                  itws[p + j] = ie + io;
                  rtws[p + j + s] = re - ro;
                  itws[p + j + s] = ie - io;
                  if (j !== l) {
                    rx = rtwdf * rtwdf_ - itwdf * itwdf_;
                    itwdf_ = rtwdf * itwdf_ + itwdf * rtwdf_;
                    rtwdf_ = rx;
                  }
                }
              }
            }
          };
          FFTM.prototype.guessLen13b = function guessLen13b(n, m) {
            var N = Math.max(m, n) | 1;
            var odd = N & 1;
            var i = 0;
            for (N = (N / 2) | 0; N; N = N >>> 1) {
              i++;
            }
            return 1 << (i + 1 + odd);
          };
          FFTM.prototype.conjugate = function conjugate(rws, iws, N) {
            if (N <= 1) return;
            for (var i = 0; i < N / 2; i++) {
              var t = rws[i];
              rws[i] = rws[N - i - 1];
              rws[N - i - 1] = t;
              t = iws[i];
              iws[i] = -iws[N - i - 1];
              iws[N - i - 1] = -t;
            }
          };
          FFTM.prototype.normalize13b = function normalize13b(ws, N) {
            var carry = 0;
            for (var i = 0; i < N / 2; i++) {
              var w =
                Math.round(ws[2 * i + 1] / N) * 8192 +
                Math.round(ws[2 * i] / N) +
                carry;
              ws[i] = w & 67108863;
              if (w < 67108864) {
                carry = 0;
              } else {
                carry = (w / 67108864) | 0;
              }
            }
            return ws;
          };
          FFTM.prototype.convert13b = function convert13b(ws, len, rws, N) {
            var carry = 0;
            for (var i = 0; i < len; i++) {
              carry = carry + (ws[i] | 0);
              rws[2 * i] = carry & 8191;
              carry = carry >>> 13;
              rws[2 * i + 1] = carry & 8191;
              carry = carry >>> 13;
            }
            for (i = 2 * len; i < N; ++i) {
              rws[i] = 0;
            }
            assert(carry === 0);
            assert((carry & ~8191) === 0);
          };
          FFTM.prototype.stub = function stub(N) {
            var ph = new Array(N);
            for (var i = 0; i < N; i++) {
              ph[i] = 0;
            }
            return ph;
          };
          FFTM.prototype.mulp = function mulp(x, y, out) {
            var N = 2 * this.guessLen13b(x.length, y.length);
            var rbt = this.makeRBT(N);
            var _ = this.stub(N);
            var rws = new Array(N);
            var rwst = new Array(N);
            var iwst = new Array(N);
            var nrws = new Array(N);
            var nrwst = new Array(N);
            var niwst = new Array(N);
            var rmws = out.words;
            rmws.length = N;
            this.convert13b(x.words, x.length, rws, N);
            this.convert13b(y.words, y.length, nrws, N);
            this.transform(rws, _, rwst, iwst, N, rbt);
            this.transform(nrws, _, nrwst, niwst, N, rbt);
            for (var i = 0; i < N; i++) {
              var rx = rwst[i] * nrwst[i] - iwst[i] * niwst[i];
              iwst[i] = rwst[i] * niwst[i] + iwst[i] * nrwst[i];
              rwst[i] = rx;
            }
            this.conjugate(rwst, iwst, N);
            this.transform(rwst, iwst, rmws, _, N, rbt);
            this.conjugate(rmws, _, N);
            this.normalize13b(rmws, N);
            out.negative = x.negative ^ y.negative;
            out.length = x.length + y.length;
            return out._strip();
          };
          BN.prototype.mul = function mul(num) {
            var out = new BN(null);
            out.words = new Array(this.length + num.length);
            return this.mulTo(num, out);
          };
          BN.prototype.mulf = function mulf(num) {
            var out = new BN(null);
            out.words = new Array(this.length + num.length);
            return jumboMulTo(this, num, out);
          };
          BN.prototype.imul = function imul(num) {
            return this.clone().mulTo(num, this);
          };
          BN.prototype.imuln = function imuln(num) {
            var isNegNum = num < 0;
            if (isNegNum) num = -num;
            assert(typeof num === "number");
            assert(num < 67108864);
            var carry = 0;
            for (var i = 0; i < this.length; i++) {
              var w = (this.words[i] | 0) * num;
              var lo = (w & 67108863) + (carry & 67108863);
              carry >>= 26;
              carry += (w / 67108864) | 0;
              carry += lo >>> 26;
              this.words[i] = lo & 67108863;
            }
            if (carry !== 0) {
              this.words[i] = carry;
              this.length++;
            }
            return isNegNum ? this.ineg() : this;
          };
          BN.prototype.muln = function muln(num) {
            return this.clone().imuln(num);
          };
          BN.prototype.sqr = function sqr() {
            return this.mul(this);
          };
          BN.prototype.isqr = function isqr() {
            return this.imul(this.clone());
          };
          BN.prototype.pow = function pow(num) {
            var w = toBitArray(num);
            if (w.length === 0) return new BN(1);
            var res = this;
            for (var i = 0; i < w.length; i++, res = res.sqr()) {
              if (w[i] !== 0) break;
            }
            if (++i < w.length) {
              for (var q = res.sqr(); i < w.length; i++, q = q.sqr()) {
                if (w[i] === 0) continue;
                res = res.mul(q);
              }
            }
            return res;
          };
          BN.prototype.iushln = function iushln(bits) {
            assert(typeof bits === "number" && bits >= 0);
            var r = bits % 26;
            var s = (bits - r) / 26;
            var carryMask = (67108863 >>> (26 - r)) << (26 - r);
            var i;
            if (r !== 0) {
              var carry = 0;
              for (i = 0; i < this.length; i++) {
                var newCarry = this.words[i] & carryMask;
                var c = ((this.words[i] | 0) - newCarry) << r;
                this.words[i] = c | carry;
                carry = newCarry >>> (26 - r);
              }
              if (carry) {
                this.words[i] = carry;
                this.length++;
              }
            }
            if (s !== 0) {
              for (i = this.length - 1; i >= 0; i--) {
                this.words[i + s] = this.words[i];
              }
              for (i = 0; i < s; i++) {
                this.words[i] = 0;
              }
              this.length += s;
            }
            return this._strip();
          };
          BN.prototype.ishln = function ishln(bits) {
            assert(this.negative === 0);
            return this.iushln(bits);
          };
          BN.prototype.iushrn = function iushrn(bits, hint, extended) {
            assert(typeof bits === "number" && bits >= 0);
            var h;
            if (hint) {
              h = (hint - (hint % 26)) / 26;
            } else {
              h = 0;
            }
            var r = bits % 26;
            var s = Math.min((bits - r) / 26, this.length);
            var mask = 67108863 ^ ((67108863 >>> r) << r);
            var maskedWords = extended;
            h -= s;
            h = Math.max(0, h);
            if (maskedWords) {
              for (var i = 0; i < s; i++) {
                maskedWords.words[i] = this.words[i];
              }
              maskedWords.length = s;
            }
            if (s === 0) {
            } else if (this.length > s) {
              this.length -= s;
              for (i = 0; i < this.length; i++) {
                this.words[i] = this.words[i + s];
              }
            } else {
              this.words[0] = 0;
              this.length = 1;
            }
            var carry = 0;
            for (i = this.length - 1; i >= 0 && (carry !== 0 || i >= h); i--) {
              var word = this.words[i] | 0;
              this.words[i] = (carry << (26 - r)) | (word >>> r);
              carry = word & mask;
            }
            if (maskedWords && carry !== 0) {
              maskedWords.words[maskedWords.length++] = carry;
            }
            if (this.length === 0) {
              this.words[0] = 0;
              this.length = 1;
            }
            return this._strip();
          };
          BN.prototype.ishrn = function ishrn(bits, hint, extended) {
            assert(this.negative === 0);
            return this.iushrn(bits, hint, extended);
          };
          BN.prototype.shln = function shln(bits) {
            return this.clone().ishln(bits);
          };
          BN.prototype.ushln = function ushln(bits) {
            return this.clone().iushln(bits);
          };
          BN.prototype.shrn = function shrn(bits) {
            return this.clone().ishrn(bits);
          };
          BN.prototype.ushrn = function ushrn(bits) {
            return this.clone().iushrn(bits);
          };
          BN.prototype.testn = function testn(bit) {
            assert(typeof bit === "number" && bit >= 0);
            var r = bit % 26;
            var s = (bit - r) / 26;
            var q = 1 << r;
            if (this.length <= s) return false;
            var w = this.words[s];
            return !!(w & q);
          };
          BN.prototype.imaskn = function imaskn(bits) {
            assert(typeof bits === "number" && bits >= 0);
            var r = bits % 26;
            var s = (bits - r) / 26;
            assert(
              this.negative === 0,
              "imaskn works only with positive numbers"
            );
            if (this.length <= s) {
              return this;
            }
            if (r !== 0) {
              s++;
            }
            this.length = Math.min(s, this.length);
            if (r !== 0) {
              var mask = 67108863 ^ ((67108863 >>> r) << r);
              this.words[this.length - 1] &= mask;
            }
            return this._strip();
          };
          BN.prototype.maskn = function maskn(bits) {
            return this.clone().imaskn(bits);
          };
          BN.prototype.iaddn = function iaddn(num) {
            assert(typeof num === "number");
            assert(num < 67108864);
            if (num < 0) return this.isubn(-num);
            if (this.negative !== 0) {
              if (this.length === 1 && (this.words[0] | 0) <= num) {
                this.words[0] = num - (this.words[0] | 0);
                this.negative = 0;
                return this;
              }
              this.negative = 0;
              this.isubn(num);
              this.negative = 1;
              return this;
            }
            return this._iaddn(num);
          };
          BN.prototype._iaddn = function _iaddn(num) {
            this.words[0] += num;
            for (var i = 0; i < this.length && this.words[i] >= 67108864; i++) {
              this.words[i] -= 67108864;
              if (i === this.length - 1) {
                this.words[i + 1] = 1;
              } else {
                this.words[i + 1]++;
              }
            }
            this.length = Math.max(this.length, i + 1);
            return this;
          };
          BN.prototype.isubn = function isubn(num) {
            assert(typeof num === "number");
            assert(num < 67108864);
            if (num < 0) return this.iaddn(-num);
            if (this.negative !== 0) {
              this.negative = 0;
              this.iaddn(num);
              this.negative = 1;
              return this;
            }
            this.words[0] -= num;
            if (this.length === 1 && this.words[0] < 0) {
              this.words[0] = -this.words[0];
              this.negative = 1;
            } else {
              for (var i = 0; i < this.length && this.words[i] < 0; i++) {
                this.words[i] += 67108864;
                this.words[i + 1] -= 1;
              }
            }
            return this._strip();
          };
          BN.prototype.addn = function addn(num) {
            return this.clone().iaddn(num);
          };
          BN.prototype.subn = function subn(num) {
            return this.clone().isubn(num);
          };
          BN.prototype.iabs = function iabs() {
            this.negative = 0;
            return this;
          };
          BN.prototype.abs = function abs() {
            return this.clone().iabs();
          };
          BN.prototype._ishlnsubmul = function _ishlnsubmul(num, mul, shift) {
            var len = num.length + shift;
            var i;
            this._expand(len);
            var w;
            var carry = 0;
            for (i = 0; i < num.length; i++) {
              w = (this.words[i + shift] | 0) + carry;
              var right = (num.words[i] | 0) * mul;
              w -= right & 67108863;
              carry = (w >> 26) - ((right / 67108864) | 0);
              this.words[i + shift] = w & 67108863;
            }
            for (; i < this.length - shift; i++) {
              w = (this.words[i + shift] | 0) + carry;
              carry = w >> 26;
              this.words[i + shift] = w & 67108863;
            }
            if (carry === 0) return this._strip();
            assert(carry === -1);
            carry = 0;
            for (i = 0; i < this.length; i++) {
              w = -(this.words[i] | 0) + carry;
              carry = w >> 26;
              this.words[i] = w & 67108863;
            }
            this.negative = 1;
            return this._strip();
          };
          BN.prototype._wordDiv = function _wordDiv(num, mode) {
            var shift = this.length - num.length;
            var a = this.clone();
            var b = num;
            var bhi = b.words[b.length - 1] | 0;
            var bhiBits = this._countBits(bhi);
            shift = 26 - bhiBits;
            if (shift !== 0) {
              b = b.ushln(shift);
              a.iushln(shift);
              bhi = b.words[b.length - 1] | 0;
            }
            var m = a.length - b.length;
            var q;
            if (mode !== "mod") {
              q = new BN(null);
              q.length = m + 1;
              q.words = new Array(q.length);
              for (var i = 0; i < q.length; i++) {
                q.words[i] = 0;
              }
            }
            var diff = a.clone()._ishlnsubmul(b, 1, m);
            if (diff.negative === 0) {
              a = diff;
              if (q) {
                q.words[m] = 1;
              }
            }
            for (var j = m - 1; j >= 0; j--) {
              var qj =
                (a.words[b.length + j] | 0) * 67108864 +
                (a.words[b.length + j - 1] | 0);
              qj = Math.min((qj / bhi) | 0, 67108863);
              a._ishlnsubmul(b, qj, j);
              while (a.negative !== 0) {
                qj--;
                a.negative = 0;
                a._ishlnsubmul(b, 1, j);
                if (!a.isZero()) {
                  a.negative ^= 1;
                }
              }
              if (q) {
                q.words[j] = qj;
              }
            }
            if (q) {
              q._strip();
            }
            a._strip();
            if (mode !== "div" && shift !== 0) {
              a.iushrn(shift);
            }
            return { div: q || null, mod: a };
          };
          BN.prototype.divmod = function divmod(num, mode, positive) {
            assert(!num.isZero());
            if (this.isZero()) {
              return { div: new BN(0), mod: new BN(0) };
            }
            var div, mod, res;
            if (this.negative !== 0 && num.negative === 0) {
              res = this.neg().divmod(num, mode);
              if (mode !== "mod") {
                div = res.div.neg();
              }
              if (mode !== "div") {
                mod = res.mod.neg();
                if (positive && mod.negative !== 0) {
                  mod.iadd(num);
                }
              }
              return { div: div, mod: mod };
            }
            if (this.negative === 0 && num.negative !== 0) {
              res = this.divmod(num.neg(), mode);
              if (mode !== "mod") {
                div = res.div.neg();
              }
              return { div: div, mod: res.mod };
            }
            if ((this.negative & num.negative) !== 0) {
              res = this.neg().divmod(num.neg(), mode);
              if (mode !== "div") {
                mod = res.mod.neg();
                if (positive && mod.negative !== 0) {
                  mod.isub(num);
                }
              }
              return { div: res.div, mod: mod };
            }
            if (num.length > this.length || this.cmp(num) < 0) {
              return { div: new BN(0), mod: this };
            }
            if (num.length === 1) {
              if (mode === "div") {
                return { div: this.divn(num.words[0]), mod: null };
              }
              if (mode === "mod") {
                return { div: null, mod: new BN(this.modrn(num.words[0])) };
              }
              return {
                div: this.divn(num.words[0]),
                mod: new BN(this.modrn(num.words[0])),
              };
            }
            return this._wordDiv(num, mode);
          };
          BN.prototype.div = function div(num) {
            return this.divmod(num, "div", false).div;
          };
          BN.prototype.mod = function mod(num) {
            return this.divmod(num, "mod", false).mod;
          };
          BN.prototype.umod = function umod(num) {
            return this.divmod(num, "mod", true).mod;
          };
          BN.prototype.divRound = function divRound(num) {
            var dm = this.divmod(num);
            if (dm.mod.isZero()) return dm.div;
            var mod = dm.div.negative !== 0 ? dm.mod.isub(num) : dm.mod;
            var half = num.ushrn(1);
            var r2 = num.andln(1);
            var cmp = mod.cmp(half);
            if (cmp < 0 || (r2 === 1 && cmp === 0)) return dm.div;
            return dm.div.negative !== 0 ? dm.div.isubn(1) : dm.div.iaddn(1);
          };
          BN.prototype.modrn = function modrn(num) {
            var isNegNum = num < 0;
            if (isNegNum) num = -num;
            assert(num <= 67108863);
            var p = (1 << 26) % num;
            var acc = 0;
            for (var i = this.length - 1; i >= 0; i--) {
              acc = (p * acc + (this.words[i] | 0)) % num;
            }
            return isNegNum ? -acc : acc;
          };
          BN.prototype.modn = function modn(num) {
            return this.modrn(num);
          };
          BN.prototype.idivn = function idivn(num) {
            var isNegNum = num < 0;
            if (isNegNum) num = -num;
            assert(num <= 67108863);
            var carry = 0;
            for (var i = this.length - 1; i >= 0; i--) {
              var w = (this.words[i] | 0) + carry * 67108864;
              this.words[i] = (w / num) | 0;
              carry = w % num;
            }
            this._strip();
            return isNegNum ? this.ineg() : this;
          };
          BN.prototype.divn = function divn(num) {
            return this.clone().idivn(num);
          };
          BN.prototype.egcd = function egcd(p) {
            assert(p.negative === 0);
            assert(!p.isZero());
            var x = this;
            var y = p.clone();
            if (x.negative !== 0) {
              x = x.umod(p);
            } else {
              x = x.clone();
            }
            var A = new BN(1);
            var B = new BN(0);
            var C = new BN(0);
            var D = new BN(1);
            var g = 0;
            while (x.isEven() && y.isEven()) {
              x.iushrn(1);
              y.iushrn(1);
              ++g;
            }
            var yp = y.clone();
            var xp = x.clone();
            while (!x.isZero()) {
              for (
                var i = 0, im = 1;
                (x.words[0] & im) === 0 && i < 26;
                ++i, im <<= 1
              );
              if (i > 0) {
                x.iushrn(i);
                while (i-- > 0) {
                  if (A.isOdd() || B.isOdd()) {
                    A.iadd(yp);
                    B.isub(xp);
                  }
                  A.iushrn(1);
                  B.iushrn(1);
                }
              }
              for (
                var j = 0, jm = 1;
                (y.words[0] & jm) === 0 && j < 26;
                ++j, jm <<= 1
              );
              if (j > 0) {
                y.iushrn(j);
                while (j-- > 0) {
                  if (C.isOdd() || D.isOdd()) {
                    C.iadd(yp);
                    D.isub(xp);
                  }
                  C.iushrn(1);
                  D.iushrn(1);
                }
              }
              if (x.cmp(y) >= 0) {
                x.isub(y);
                A.isub(C);
                B.isub(D);
              } else {
                y.isub(x);
                C.isub(A);
                D.isub(B);
              }
            }
            return { a: C, b: D, gcd: y.iushln(g) };
          };
          BN.prototype._invmp = function _invmp(p) {
            assert(p.negative === 0);
            assert(!p.isZero());
            var a = this;
            var b = p.clone();
            if (a.negative !== 0) {
              a = a.umod(p);
            } else {
              a = a.clone();
            }
            var x1 = new BN(1);
            var x2 = new BN(0);
            var delta = b.clone();
            while (a.cmpn(1) > 0 && b.cmpn(1) > 0) {
              for (
                var i = 0, im = 1;
                (a.words[0] & im) === 0 && i < 26;
                ++i, im <<= 1
              );
              if (i > 0) {
                a.iushrn(i);
                while (i-- > 0) {
                  if (x1.isOdd()) {
                    x1.iadd(delta);
                  }
                  x1.iushrn(1);
                }
              }
              for (
                var j = 0, jm = 1;
                (b.words[0] & jm) === 0 && j < 26;
                ++j, jm <<= 1
              );
              if (j > 0) {
                b.iushrn(j);
                while (j-- > 0) {
                  if (x2.isOdd()) {
                    x2.iadd(delta);
                  }
                  x2.iushrn(1);
                }
              }
              if (a.cmp(b) >= 0) {
                a.isub(b);
                x1.isub(x2);
              } else {
                b.isub(a);
                x2.isub(x1);
              }
            }
            var res;
            if (a.cmpn(1) === 0) {
              res = x1;
            } else {
              res = x2;
            }
            if (res.cmpn(0) < 0) {
              res.iadd(p);
            }
            return res;
          };
          BN.prototype.gcd = function gcd(num) {
            if (this.isZero()) return num.abs();
            if (num.isZero()) return this.abs();
            var a = this.clone();
            var b = num.clone();
            a.negative = 0;
            b.negative = 0;
            for (var shift = 0; a.isEven() && b.isEven(); shift++) {
              a.iushrn(1);
              b.iushrn(1);
            }
            do {
              while (a.isEven()) {
                a.iushrn(1);
              }
              while (b.isEven()) {
                b.iushrn(1);
              }
              var r = a.cmp(b);
              if (r < 0) {
                var t = a;
                a = b;
                b = t;
              } else if (r === 0 || b.cmpn(1) === 0) {
                break;
              }
              a.isub(b);
            } while (true);
            return b.iushln(shift);
          };
          BN.prototype.invm = function invm(num) {
            return this.egcd(num).a.umod(num);
          };
          BN.prototype.isEven = function isEven() {
            return (this.words[0] & 1) === 0;
          };
          BN.prototype.isOdd = function isOdd() {
            return (this.words[0] & 1) === 1;
          };
          BN.prototype.andln = function andln(num) {
            return this.words[0] & num;
          };
          BN.prototype.bincn = function bincn(bit) {
            assert(typeof bit === "number");
            var r = bit % 26;
            var s = (bit - r) / 26;
            var q = 1 << r;
            if (this.length <= s) {
              this._expand(s + 1);
              this.words[s] |= q;
              return this;
            }
            var carry = q;
            for (var i = s; carry !== 0 && i < this.length; i++) {
              var w = this.words[i] | 0;
              w += carry;
              carry = w >>> 26;
              w &= 67108863;
              this.words[i] = w;
            }
            if (carry !== 0) {
              this.words[i] = carry;
              this.length++;
            }
            return this;
          };
          BN.prototype.isZero = function isZero() {
            return this.length === 1 && this.words[0] === 0;
          };
          BN.prototype.cmpn = function cmpn(num) {
            var negative = num < 0;
            if (this.negative !== 0 && !negative) return -1;
            if (this.negative === 0 && negative) return 1;
            this._strip();
            var res;
            if (this.length > 1) {
              res = 1;
            } else {
              if (negative) {
                num = -num;
              }
              assert(num <= 67108863, "Number is too big");
              var w = this.words[0] | 0;
              res = w === num ? 0 : w < num ? -1 : 1;
            }
            if (this.negative !== 0) return -res | 0;
            return res;
          };
          BN.prototype.cmp = function cmp(num) {
            if (this.negative !== 0 && num.negative === 0) return -1;
            if (this.negative === 0 && num.negative !== 0) return 1;
            var res = this.ucmp(num);
            if (this.negative !== 0) return -res | 0;
            return res;
          };
          BN.prototype.ucmp = function ucmp(num) {
            if (this.length > num.length) return 1;
            if (this.length < num.length) return -1;
            var res = 0;
            for (var i = this.length - 1; i >= 0; i--) {
              var a = this.words[i] | 0;
              var b = num.words[i] | 0;
              if (a === b) continue;
              if (a < b) {
                res = -1;
              } else if (a > b) {
                res = 1;
              }
              break;
            }
            return res;
          };
          BN.prototype.gtn = function gtn(num) {
            return this.cmpn(num) === 1;
          };
          BN.prototype.gt = function gt(num) {
            return this.cmp(num) === 1;
          };
          BN.prototype.gten = function gten(num) {
            return this.cmpn(num) >= 0;
          };
          BN.prototype.gte = function gte(num) {
            return this.cmp(num) >= 0;
          };
          BN.prototype.ltn = function ltn(num) {
            return this.cmpn(num) === -1;
          };
          BN.prototype.lt = function lt(num) {
            return this.cmp(num) === -1;
          };
          BN.prototype.lten = function lten(num) {
            return this.cmpn(num) <= 0;
          };
          BN.prototype.lte = function lte(num) {
            return this.cmp(num) <= 0;
          };
          BN.prototype.eqn = function eqn(num) {
            return this.cmpn(num) === 0;
          };
          BN.prototype.eq = function eq(num) {
            return this.cmp(num) === 0;
          };
          BN.red = function red(num) {
            return new Red(num);
          };
          BN.prototype.toRed = function toRed(ctx) {
            assert(!this.red, "Already a number in reduction context");
            assert(this.negative === 0, "red works only with positives");
            return ctx.convertTo(this)._forceRed(ctx);
          };
          BN.prototype.fromRed = function fromRed() {
            assert(
              this.red,
              "fromRed works only with numbers in reduction context"
            );
            return this.red.convertFrom(this);
          };
          BN.prototype._forceRed = function _forceRed(ctx) {
            this.red = ctx;
            return this;
          };
          BN.prototype.forceRed = function forceRed(ctx) {
            assert(!this.red, "Already a number in reduction context");
            return this._forceRed(ctx);
          };
          BN.prototype.redAdd = function redAdd(num) {
            assert(this.red, "redAdd works only with red numbers");
            return this.red.add(this, num);
          };
          BN.prototype.redIAdd = function redIAdd(num) {
            assert(this.red, "redIAdd works only with red numbers");
            return this.red.iadd(this, num);
          };
          BN.prototype.redSub = function redSub(num) {
            assert(this.red, "redSub works only with red numbers");
            return this.red.sub(this, num);
          };
          BN.prototype.redISub = function redISub(num) {
            assert(this.red, "redISub works only with red numbers");
            return this.red.isub(this, num);
          };
          BN.prototype.redShl = function redShl(num) {
            assert(this.red, "redShl works only with red numbers");
            return this.red.shl(this, num);
          };
          BN.prototype.redMul = function redMul(num) {
            assert(this.red, "redMul works only with red numbers");
            this.red._verify2(this, num);
            return this.red.mul(this, num);
          };
          BN.prototype.redIMul = function redIMul(num) {
            assert(this.red, "redMul works only with red numbers");
            this.red._verify2(this, num);
            return this.red.imul(this, num);
          };
          BN.prototype.redSqr = function redSqr() {
            assert(this.red, "redSqr works only with red numbers");
            this.red._verify1(this);
            return this.red.sqr(this);
          };
          BN.prototype.redISqr = function redISqr() {
            assert(this.red, "redISqr works only with red numbers");
            this.red._verify1(this);
            return this.red.isqr(this);
          };
          BN.prototype.redSqrt = function redSqrt() {
            assert(this.red, "redSqrt works only with red numbers");
            this.red._verify1(this);
            return this.red.sqrt(this);
          };
          BN.prototype.redInvm = function redInvm() {
            assert(this.red, "redInvm works only with red numbers");
            this.red._verify1(this);
            return this.red.invm(this);
          };
          BN.prototype.redNeg = function redNeg() {
            assert(this.red, "redNeg works only with red numbers");
            this.red._verify1(this);
            return this.red.neg(this);
          };
          BN.prototype.redPow = function redPow(num) {
            assert(this.red && !num.red, "redPow(normalNum)");
            this.red._verify1(this);
            return this.red.pow(this, num);
          };
          var primes = { k256: null, p224: null, p192: null, p25519: null };
          function MPrime(name, p) {
            this.name = name;
            this.p = new BN(p, 16);
            this.n = this.p.bitLength();
            this.k = new BN(1).iushln(this.n).isub(this.p);
            this.tmp = this._tmp();
          }
          MPrime.prototype._tmp = function _tmp() {
            var tmp = new BN(null);
            tmp.words = new Array(Math.ceil(this.n / 13));
            return tmp;
          };
          MPrime.prototype.ireduce = function ireduce(num) {
            var r = num;
            var rlen;
            do {
              this.split(r, this.tmp);
              r = this.imulK(r);
              r = r.iadd(this.tmp);
              rlen = r.bitLength();
            } while (rlen > this.n);
            var cmp = rlen < this.n ? -1 : r.ucmp(this.p);
            if (cmp === 0) {
              r.words[0] = 0;
              r.length = 1;
            } else if (cmp > 0) {
              r.isub(this.p);
            } else {
              if (r.strip !== undefined) {
                r.strip();
              } else {
                r._strip();
              }
            }
            return r;
          };
          MPrime.prototype.split = function split(input, out) {
            input.iushrn(this.n, 0, out);
          };
          MPrime.prototype.imulK = function imulK(num) {
            return num.imul(this.k);
          };
          function K256() {
            MPrime.call(
              this,
              "k256",
              "ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff fffffffe fffffc2f"
            );
          }
          inherits(K256, MPrime);
          K256.prototype.split = function split(input, output) {
            var mask = 4194303;
            var outLen = Math.min(input.length, 9);
            for (var i = 0; i < outLen; i++) {
              output.words[i] = input.words[i];
            }
            output.length = outLen;
            if (input.length <= 9) {
              input.words[0] = 0;
              input.length = 1;
              return;
            }
            var prev = input.words[9];
            output.words[output.length++] = prev & mask;
            for (i = 10; i < input.length; i++) {
              var next = input.words[i] | 0;
              input.words[i - 10] = ((next & mask) << 4) | (prev >>> 22);
              prev = next;
            }
            prev >>>= 22;
            input.words[i - 10] = prev;
            if (prev === 0 && input.length > 10) {
              input.length -= 10;
            } else {
              input.length -= 9;
            }
          };
          K256.prototype.imulK = function imulK(num) {
            num.words[num.length] = 0;
            num.words[num.length + 1] = 0;
            num.length += 2;
            var lo = 0;
            for (var i = 0; i < num.length; i++) {
              var w = num.words[i] | 0;
              lo += w * 977;
              num.words[i] = lo & 67108863;
              lo = w * 64 + ((lo / 67108864) | 0);
            }
            if (num.words[num.length - 1] === 0) {
              num.length--;
              if (num.words[num.length - 1] === 0) {
                num.length--;
              }
            }
            return num;
          };
          function P224() {
            MPrime.call(
              this,
              "p224",
              "ffffffff ffffffff ffffffff ffffffff 00000000 00000000 00000001"
            );
          }
          inherits(P224, MPrime);
          function P192() {
            MPrime.call(
              this,
              "p192",
              "ffffffff ffffffff ffffffff fffffffe ffffffff ffffffff"
            );
          }
          inherits(P192, MPrime);
          function P25519() {
            MPrime.call(
              this,
              "25519",
              "7fffffffffffffff ffffffffffffffff ffffffffffffffff ffffffffffffffed"
            );
          }
          inherits(P25519, MPrime);
          P25519.prototype.imulK = function imulK(num) {
            var carry = 0;
            for (var i = 0; i < num.length; i++) {
              var hi = (num.words[i] | 0) * 19 + carry;
              var lo = hi & 67108863;
              hi >>>= 26;
              num.words[i] = lo;
              carry = hi;
            }
            if (carry !== 0) {
              num.words[num.length++] = carry;
            }
            return num;
          };
          BN._prime = function prime(name) {
            if (primes[name]) return primes[name];
            var prime;
            if (name === "k256") {
              prime = new K256();
            } else if (name === "p224") {
              prime = new P224();
            } else if (name === "p192") {
              prime = new P192();
            } else if (name === "p25519") {
              prime = new P25519();
            } else {
              throw new Error("Unknown prime " + name);
            }
            primes[name] = prime;
            return prime;
          };
          function Red(m) {
            if (typeof m === "string") {
              var prime = BN._prime(m);
              this.m = prime.p;
              this.prime = prime;
            } else {
              assert(m.gtn(1), "modulus must be greater than 1");
              this.m = m;
              this.prime = null;
            }
          }
          Red.prototype._verify1 = function _verify1(a) {
            assert(a.negative === 0, "red works only with positives");
            assert(a.red, "red works only with red numbers");
          };
          Red.prototype._verify2 = function _verify2(a, b) {
            assert(
              (a.negative | b.negative) === 0,
              "red works only with positives"
            );
            assert(a.red && a.red === b.red, "red works only with red numbers");
          };
          Red.prototype.imod = function imod(a) {
            if (this.prime) return this.prime.ireduce(a)._forceRed(this);
            move(a, a.umod(this.m)._forceRed(this));
            return a;
          };
          Red.prototype.neg = function neg(a) {
            if (a.isZero()) {
              return a.clone();
            }
            return this.m.sub(a)._forceRed(this);
          };
          Red.prototype.add = function add(a, b) {
            this._verify2(a, b);
            var res = a.add(b);
            if (res.cmp(this.m) >= 0) {
              res.isub(this.m);
            }
            return res._forceRed(this);
          };
          Red.prototype.iadd = function iadd(a, b) {
            this._verify2(a, b);
            var res = a.iadd(b);
            if (res.cmp(this.m) >= 0) {
              res.isub(this.m);
            }
            return res;
          };
          Red.prototype.sub = function sub(a, b) {
            this._verify2(a, b);
            var res = a.sub(b);
            if (res.cmpn(0) < 0) {
              res.iadd(this.m);
            }
            return res._forceRed(this);
          };
          Red.prototype.isub = function isub(a, b) {
            this._verify2(a, b);
            var res = a.isub(b);
            if (res.cmpn(0) < 0) {
              res.iadd(this.m);
            }
            return res;
          };
          Red.prototype.shl = function shl(a, num) {
            this._verify1(a);
            return this.imod(a.ushln(num));
          };
          Red.prototype.imul = function imul(a, b) {
            this._verify2(a, b);
            return this.imod(a.imul(b));
          };
          Red.prototype.mul = function mul(a, b) {
            this._verify2(a, b);
            return this.imod(a.mul(b));
          };
          Red.prototype.isqr = function isqr(a) {
            return this.imul(a, a.clone());
          };
          Red.prototype.sqr = function sqr(a) {
            return this.mul(a, a);
          };
          Red.prototype.sqrt = function sqrt(a) {
            if (a.isZero()) return a.clone();
            var mod3 = this.m.andln(3);
            assert(mod3 % 2 === 1);
            if (mod3 === 3) {
              var pow = this.m.add(new BN(1)).iushrn(2);
              return this.pow(a, pow);
            }
            var q = this.m.subn(1);
            var s = 0;
            while (!q.isZero() && q.andln(1) === 0) {
              s++;
              q.iushrn(1);
            }
            assert(!q.isZero());
            var one = new BN(1).toRed(this);
            var nOne = one.redNeg();
            var lpow = this.m.subn(1).iushrn(1);
            var z = this.m.bitLength();
            z = new BN(2 * z * z).toRed(this);
            while (this.pow(z, lpow).cmp(nOne) !== 0) {
              z.redIAdd(nOne);
            }
            var c = this.pow(z, q);
            var r = this.pow(a, q.addn(1).iushrn(1));
            var t = this.pow(a, q);
            var m = s;
            while (t.cmp(one) !== 0) {
              var tmp = t;
              for (var i = 0; tmp.cmp(one) !== 0; i++) {
                tmp = tmp.redSqr();
              }
              assert(i < m);
              var b = this.pow(c, new BN(1).iushln(m - i - 1));
              r = r.redMul(b);
              c = b.redSqr();
              t = t.redMul(c);
              m = i;
            }
            return r;
          };
          Red.prototype.invm = function invm(a) {
            var inv = a._invmp(this.m);
            if (inv.negative !== 0) {
              inv.negative = 0;
              return this.imod(inv).redNeg();
            } else {
              return this.imod(inv);
            }
          };
          Red.prototype.pow = function pow(a, num) {
            if (num.isZero()) return new BN(1).toRed(this);
            if (num.cmpn(1) === 0) return a.clone();
            var windowSize = 4;
            var wnd = new Array(1 << windowSize);
            wnd[0] = new BN(1).toRed(this);
            wnd[1] = a;
            for (var i = 2; i < wnd.length; i++) {
              wnd[i] = this.mul(wnd[i - 1], a);
            }
            var res = wnd[0];
            var current = 0;
            var currentLen = 0;
            var start = num.bitLength() % 26;
            if (start === 0) {
              start = 26;
            }
            for (i = num.length - 1; i >= 0; i--) {
              var word = num.words[i];
              for (var j = start - 1; j >= 0; j--) {
                var bit = (word >> j) & 1;
                if (res !== wnd[0]) {
                  res = this.sqr(res);
                }
                if (bit === 0 && current === 0) {
                  currentLen = 0;
                  continue;
                }
                current <<= 1;
                current |= bit;
                currentLen++;
                if (currentLen !== windowSize && (i !== 0 || j !== 0)) continue;
                res = this.mul(res, wnd[current]);
                currentLen = 0;
                current = 0;
              }
              start = 26;
            }
            return res;
          };
          Red.prototype.convertTo = function convertTo(num) {
            var r = num.umod(this.m);
            return r === num ? r.clone() : r;
          };
          Red.prototype.convertFrom = function convertFrom(num) {
            var res = num.clone();
            res.red = null;
            return res;
          };
          BN.mont = function mont(num) {
            return new Mont(num);
          };
          function Mont(m) {
            Red.call(this, m);
            this.shift = this.m.bitLength();
            if (this.shift % 26 !== 0) {
              this.shift += 26 - (this.shift % 26);
            }
            this.r = new BN(1).iushln(this.shift);
            this.r2 = this.imod(this.r.sqr());
            this.rinv = this.r._invmp(this.m);
            this.minv = this.rinv.mul(this.r).isubn(1).div(this.m);
            this.minv = this.minv.umod(this.r);
            this.minv = this.r.sub(this.minv);
          }
          inherits(Mont, Red);
          Mont.prototype.convertTo = function convertTo(num) {
            return this.imod(num.ushln(this.shift));
          };
          Mont.prototype.convertFrom = function convertFrom(num) {
            var r = this.imod(num.mul(this.rinv));
            r.red = null;
            return r;
          };
          Mont.prototype.imul = function imul(a, b) {
            if (a.isZero() || b.isZero()) {
              a.words[0] = 0;
              a.length = 1;
              return a;
            }
            var t = a.imul(b);
            var c = t
              .maskn(this.shift)
              .mul(this.minv)
              .imaskn(this.shift)
              .mul(this.m);
            var u = t.isub(c).iushrn(this.shift);
            var res = u;
            if (u.cmp(this.m) >= 0) {
              res = u.isub(this.m);
            } else if (u.cmpn(0) < 0) {
              res = u.iadd(this.m);
            }
            return res._forceRed(this);
          };
          Mont.prototype.mul = function mul(a, b) {
            if (a.isZero() || b.isZero()) return new BN(0)._forceRed(this);
            var t = a.mul(b);
            var c = t
              .maskn(this.shift)
              .mul(this.minv)
              .imaskn(this.shift)
              .mul(this.m);
            var u = t.isub(c).iushrn(this.shift);
            var res = u;
            if (u.cmp(this.m) >= 0) {
              res = u.isub(this.m);
            } else if (u.cmpn(0) < 0) {
              res = u.iadd(this.m);
            }
            return res._forceRed(this);
          };
          Mont.prototype.invm = function invm(a) {
            var res = this.imod(a._invmp(this.m).mul(this.r2));
            return res._forceRed(this);
          };
        })(typeof module === "undefined" || module, this);
      },
      { buffer: 24 },
    ],
    23: [
      function (require, module, exports) {
        var r;
        module.exports = function rand(len) {
          if (!r) r = new Rand(null);
          return r.generate(len);
        };
        function Rand(rand) {
          this.rand = rand;
        }
        module.exports.Rand = Rand;
        Rand.prototype.generate = function generate(len) {
          return this._rand(len);
        };
        Rand.prototype._rand = function _rand(n) {
          if (this.rand.getBytes) return this.rand.getBytes(n);
          var res = new Uint8Array(n);
          for (var i = 0; i < res.length; i++) res[i] = this.rand.getByte();
          return res;
        };
        if (typeof self === "object") {
          if (self.crypto && self.crypto.getRandomValues) {
            Rand.prototype._rand = function _rand(n) {
              var arr = new Uint8Array(n);
              self.crypto.getRandomValues(arr);
              return arr;
            };
          } else if (self.msCrypto && self.msCrypto.getRandomValues) {
            Rand.prototype._rand = function _rand(n) {
              var arr = new Uint8Array(n);
              self.msCrypto.getRandomValues(arr);
              return arr;
            };
          } else if (typeof window === "object") {
            Rand.prototype._rand = function () {
              throw new Error("Not implemented yet");
            };
          }
        } else {
          try {
            var crypto = require("crypto");
            if (typeof crypto.randomBytes !== "function")
              throw new Error("Not supported");
            Rand.prototype._rand = function _rand(n) {
              return crypto.randomBytes(n);
            };
          } catch (e) {}
        }
      },
      { crypto: 24 },
    ],
    24: [function (require, module, exports) {}, {}],
    25: [
      function (require, module, exports) {
        (function (Buffer) {
          (function () {
            "use strict";
            var base64 = require("base64-js");
            var ieee754 = require("ieee754");
            exports.Buffer = Buffer;
            exports.SlowBuffer = SlowBuffer;
            exports.INSPECT_MAX_BYTES = 50;
            var K_MAX_LENGTH = 2147483647;
            exports.kMaxLength = K_MAX_LENGTH;
            Buffer.TYPED_ARRAY_SUPPORT = typedArraySupport();
            if (
              !Buffer.TYPED_ARRAY_SUPPORT &&
              typeof console !== "undefined" &&
              typeof console.error === "function"
            ) {
              console.error(
                "This browser lacks typed array (Uint8Array) support which is required by " +
                  "`buffer` v5.x. Use `buffer` v4.x if you require old browser support."
              );
            }
            function typedArraySupport() {
              try {
                var arr = new Uint8Array(1);
                arr.__proto__ = {
                  __proto__: Uint8Array.prototype,
                  foo: function () {
                    return 42;
                  },
                };
                return arr.foo() === 42;
              } catch (e) {
                return false;
              }
            }
            Object.defineProperty(Buffer.prototype, "parent", {
              enumerable: true,
              get: function () {
                if (!Buffer.isBuffer(this)) return undefined;
                return this.buffer;
              },
            });
            Object.defineProperty(Buffer.prototype, "offset", {
              enumerable: true,
              get: function () {
                if (!Buffer.isBuffer(this)) return undefined;
                return this.byteOffset;
              },
            });
            function createBuffer(length) {
              if (length > K_MAX_LENGTH) {
                throw new RangeError(
                  'The value "' + length + '" is invalid for option "size"'
                );
              }
              var buf = new Uint8Array(length);
              buf.__proto__ = Buffer.prototype;
              return buf;
            }
            function Buffer(arg, encodingOrOffset, length) {
              if (typeof arg === "number") {
                if (typeof encodingOrOffset === "string") {
                  throw new TypeError(
                    'The "string" argument must be of type string. Received type number'
                  );
                }
                return allocUnsafe(arg);
              }
              return from(arg, encodingOrOffset, length);
            }
            if (
              typeof Symbol !== "undefined" &&
              Symbol.species != null &&
              Buffer[Symbol.species] === Buffer
            ) {
              Object.defineProperty(Buffer, Symbol.species, {
                value: null,
                configurable: true,
                enumerable: false,
                writable: false,
              });
            }
            Buffer.poolSize = 8192;
            function from(value, encodingOrOffset, length) {
              if (typeof value === "string") {
                return fromString(value, encodingOrOffset);
              }
              if (ArrayBuffer.isView(value)) {
                return fromArrayLike(value);
              }
              if (value == null) {
                throw TypeError(
                  "The first argument must be one of type string, Buffer, ArrayBuffer, Array, " +
                    "or Array-like Object. Received type " +
                    typeof value
                );
              }
              if (
                isInstance(value, ArrayBuffer) ||
                (value && isInstance(value.buffer, ArrayBuffer))
              ) {
                return fromArrayBuffer(value, encodingOrOffset, length);
              }
              if (typeof value === "number") {
                throw new TypeError(
                  'The "value" argument must not be of type number. Received type number'
                );
              }
              var valueOf = value.valueOf && value.valueOf();
              if (valueOf != null && valueOf !== value) {
                return Buffer.from(valueOf, encodingOrOffset, length);
              }
              var b = fromObject(value);
              if (b) return b;
              if (
                typeof Symbol !== "undefined" &&
                Symbol.toPrimitive != null &&
                typeof value[Symbol.toPrimitive] === "function"
              ) {
                return Buffer.from(
                  value[Symbol.toPrimitive]("string"),
                  encodingOrOffset,
                  length
                );
              }
              throw new TypeError(
                "The first argument must be one of type string, Buffer, ArrayBuffer, Array, " +
                  "or Array-like Object. Received type " +
                  typeof value
              );
            }
            Buffer.from = function (value, encodingOrOffset, length) {
              return from(value, encodingOrOffset, length);
            };
            Buffer.prototype.__proto__ = Uint8Array.prototype;
            Buffer.__proto__ = Uint8Array;
            function assertSize(size) {
              if (typeof size !== "number") {
                throw new TypeError('"size" argument must be of type number');
              } else if (size < 0) {
                throw new RangeError(
                  'The value "' + size + '" is invalid for option "size"'
                );
              }
            }
            function alloc(size, fill, encoding) {
              assertSize(size);
              if (size <= 0) {
                return createBuffer(size);
              }
              if (fill !== undefined) {
                return typeof encoding === "string"
                  ? createBuffer(size).fill(fill, encoding)
                  : createBuffer(size).fill(fill);
              }
              return createBuffer(size);
            }
            Buffer.alloc = function (size, fill, encoding) {
              return alloc(size, fill, encoding);
            };
            function allocUnsafe(size) {
              assertSize(size);
              return createBuffer(size < 0 ? 0 : checked(size) | 0);
            }
            Buffer.allocUnsafe = function (size) {
              return allocUnsafe(size);
            };
            Buffer.allocUnsafeSlow = function (size) {
              return allocUnsafe(size);
            };
            function fromString(string, encoding) {
              if (typeof encoding !== "string" || encoding === "") {
                encoding = "utf8";
              }
              if (!Buffer.isEncoding(encoding)) {
                throw new TypeError("Unknown encoding: " + encoding);
              }
              var length = byteLength(string, encoding) | 0;
              var buf = createBuffer(length);
              var actual = buf.write(string, encoding);
              if (actual !== length) {
                buf = buf.slice(0, actual);
              }
              return buf;
            }
            function fromArrayLike(array) {
              var length = array.length < 0 ? 0 : checked(array.length) | 0;
              var buf = createBuffer(length);
              for (var i = 0; i < length; i += 1) {
                buf[i] = array[i] & 255;
              }
              return buf;
            }
            function fromArrayBuffer(array, byteOffset, length) {
              if (byteOffset < 0 || array.byteLength < byteOffset) {
                throw new RangeError('"offset" is outside of buffer bounds');
              }
              if (array.byteLength < byteOffset + (length || 0)) {
                throw new RangeError('"length" is outside of buffer bounds');
              }
              var buf;
              if (byteOffset === undefined && length === undefined) {
                buf = new Uint8Array(array);
              } else if (length === undefined) {
                buf = new Uint8Array(array, byteOffset);
              } else {
                buf = new Uint8Array(array, byteOffset, length);
              }
              buf.__proto__ = Buffer.prototype;
              return buf;
            }
            function fromObject(obj) {
              if (Buffer.isBuffer(obj)) {
                var len = checked(obj.length) | 0;
                var buf = createBuffer(len);
                if (buf.length === 0) {
                  return buf;
                }
                obj.copy(buf, 0, 0, len);
                return buf;
              }
              if (obj.length !== undefined) {
                if (typeof obj.length !== "number" || numberIsNaN(obj.length)) {
                  return createBuffer(0);
                }
                return fromArrayLike(obj);
              }
              if (obj.type === "Buffer" && Array.isArray(obj.data)) {
                return fromArrayLike(obj.data);
              }
            }
            function checked(length) {
              if (length >= K_MAX_LENGTH) {
                throw new RangeError(
                  "Attempt to allocate Buffer larger than maximum " +
                    "size: 0x" +
                    K_MAX_LENGTH.toString(16) +
                    " bytes"
                );
              }
              return length | 0;
            }
            function SlowBuffer(length) {
              if (+length != length) {
                length = 0;
              }
              return Buffer.alloc(+length);
            }
            Buffer.isBuffer = function isBuffer(b) {
              return (
                b != null && b._isBuffer === true && b !== Buffer.prototype
              );
            };
            Buffer.compare = function compare(a, b) {
              if (isInstance(a, Uint8Array))
                a = Buffer.from(a, a.offset, a.byteLength);
              if (isInstance(b, Uint8Array))
                b = Buffer.from(b, b.offset, b.byteLength);
              if (!Buffer.isBuffer(a) || !Buffer.isBuffer(b)) {
                throw new TypeError(
                  'The "buf1", "buf2" arguments must be one of type Buffer or Uint8Array'
                );
              }
              if (a === b) return 0;
              var x = a.length;
              var y = b.length;
              for (var i = 0, len = Math.min(x, y); i < len; ++i) {
                if (a[i] !== b[i]) {
                  x = a[i];
                  y = b[i];
                  break;
                }
              }
              if (x < y) return -1;
              if (y < x) return 1;
              return 0;
            };
            Buffer.isEncoding = function isEncoding(encoding) {
              switch (String(encoding).toLowerCase()) {
                case "hex":
                case "utf8":
                case "utf-8":
                case "ascii":
                case "latin1":
                case "binary":
                case "base64":
                case "ucs2":
                case "ucs-2":
                case "utf16le":
                case "utf-16le":
                  return true;
                default:
                  return false;
              }
            };
            Buffer.concat = function concat(list, length) {
              if (!Array.isArray(list)) {
                throw new TypeError(
                  '"list" argument must be an Array of Buffers'
                );
              }
              if (list.length === 0) {
                return Buffer.alloc(0);
              }
              var i;
              if (length === undefined) {
                length = 0;
                for (i = 0; i < list.length; ++i) {
                  length += list[i].length;
                }
              }
              var buffer = Buffer.allocUnsafe(length);
              var pos = 0;
              for (i = 0; i < list.length; ++i) {
                var buf = list[i];
                if (isInstance(buf, Uint8Array)) {
                  buf = Buffer.from(buf);
                }
                if (!Buffer.isBuffer(buf)) {
                  throw new TypeError(
                    '"list" argument must be an Array of Buffers'
                  );
                }
                buf.copy(buffer, pos);
                pos += buf.length;
              }
              return buffer;
            };
            function byteLength(string, encoding) {
              if (Buffer.isBuffer(string)) {
                return string.length;
              }
              if (
                ArrayBuffer.isView(string) ||
                isInstance(string, ArrayBuffer)
              ) {
                return string.byteLength;
              }
              if (typeof string !== "string") {
                throw new TypeError(
                  'The "string" argument must be one of type string, Buffer, or ArrayBuffer. ' +
                    "Received type " +
                    typeof string
                );
              }
              var len = string.length;
              var mustMatch = arguments.length > 2 && arguments[2] === true;
              if (!mustMatch && len === 0) return 0;
              var loweredCase = false;
              for (;;) {
                switch (encoding) {
                  case "ascii":
                  case "latin1":
                  case "binary":
                    return len;
                  case "utf8":
                  case "utf-8":
                    return utf8ToBytes(string).length;
                  case "ucs2":
                  case "ucs-2":
                  case "utf16le":
                  case "utf-16le":
                    return len * 2;
                  case "hex":
                    return len >>> 1;
                  case "base64":
                    return base64ToBytes(string).length;
                  default:
                    if (loweredCase) {
                      return mustMatch ? -1 : utf8ToBytes(string).length;
                    }
                    encoding = ("" + encoding).toLowerCase();
                    loweredCase = true;
                }
              }
            }
            Buffer.byteLength = byteLength;
            function slowToString(encoding, start, end) {
              var loweredCase = false;
              if (start === undefined || start < 0) {
                start = 0;
              }
              if (start > this.length) {
                return "";
              }
              if (end === undefined || end > this.length) {
                end = this.length;
              }
              if (end <= 0) {
                return "";
              }
              end >>>= 0;
              start >>>= 0;
              if (end <= start) {
                return "";
              }
              if (!encoding) encoding = "utf8";
              while (true) {
                switch (encoding) {
                  case "hex":
                    return hexSlice(this, start, end);
                  case "utf8":
                  case "utf-8":
                    return utf8Slice(this, start, end);
                  case "ascii":
                    return asciiSlice(this, start, end);
                  case "latin1":
                  case "binary":
                    return latin1Slice(this, start, end);
                  case "base64":
                    return base64Slice(this, start, end);
                  case "ucs2":
                  case "ucs-2":
                  case "utf16le":
                  case "utf-16le":
                    return utf16leSlice(this, start, end);
                  default:
                    if (loweredCase)
                      throw new TypeError("Unknown encoding: " + encoding);
                    encoding = (encoding + "").toLowerCase();
                    loweredCase = true;
                }
              }
            }
            Buffer.prototype._isBuffer = true;
            function swap(b, n, m) {
              var i = b[n];
              b[n] = b[m];
              b[m] = i;
            }
            Buffer.prototype.swap16 = function swap16() {
              var len = this.length;
              if (len % 2 !== 0) {
                throw new RangeError(
                  "Buffer size must be a multiple of 16-bits"
                );
              }
              for (var i = 0; i < len; i += 2) {
                swap(this, i, i + 1);
              }
              return this;
            };
            Buffer.prototype.swap32 = function swap32() {
              var len = this.length;
              if (len % 4 !== 0) {
                throw new RangeError(
                  "Buffer size must be a multiple of 32-bits"
                );
              }
              for (var i = 0; i < len; i += 4) {
                swap(this, i, i + 3);
                swap(this, i + 1, i + 2);
              }
              return this;
            };
            Buffer.prototype.swap64 = function swap64() {
              var len = this.length;
              if (len % 8 !== 0) {
                throw new RangeError(
                  "Buffer size must be a multiple of 64-bits"
                );
              }
              for (var i = 0; i < len; i += 8) {
                swap(this, i, i + 7);
                swap(this, i + 1, i + 6);
                swap(this, i + 2, i + 5);
                swap(this, i + 3, i + 4);
              }
              return this;
            };
            Buffer.prototype.toString = function toString() {
              var length = this.length;
              if (length === 0) return "";
              if (arguments.length === 0) return utf8Slice(this, 0, length);
              return slowToString.apply(this, arguments);
            };
            Buffer.prototype.toLocaleString = Buffer.prototype.toString;
            Buffer.prototype.equals = function equals(b) {
              if (!Buffer.isBuffer(b))
                throw new TypeError("Argument must be a Buffer");
              if (this === b) return true;
              return Buffer.compare(this, b) === 0;
            };
            Buffer.prototype.inspect = function inspect() {
              var str = "";
              var max = exports.INSPECT_MAX_BYTES;
              str = this.toString("hex", 0, max)
                .replace(/(.{2})/g, "$1 ")
                .trim();
              if (this.length > max) str += " ... ";
              return "<Buffer " + str + ">";
            };
            Buffer.prototype.compare = function compare(
              target,
              start,
              end,
              thisStart,
              thisEnd
            ) {
              if (isInstance(target, Uint8Array)) {
                target = Buffer.from(target, target.offset, target.byteLength);
              }
              if (!Buffer.isBuffer(target)) {
                throw new TypeError(
                  'The "target" argument must be one of type Buffer or Uint8Array. ' +
                    "Received type " +
                    typeof target
                );
              }
              if (start === undefined) {
                start = 0;
              }
              if (end === undefined) {
                end = target ? target.length : 0;
              }
              if (thisStart === undefined) {
                thisStart = 0;
              }
              if (thisEnd === undefined) {
                thisEnd = this.length;
              }
              if (
                start < 0 ||
                end > target.length ||
                thisStart < 0 ||
                thisEnd > this.length
              ) {
                throw new RangeError("out of range index");
              }
              if (thisStart >= thisEnd && start >= end) {
                return 0;
              }
              if (thisStart >= thisEnd) {
                return -1;
              }
              if (start >= end) {
                return 1;
              }
              start >>>= 0;
              end >>>= 0;
              thisStart >>>= 0;
              thisEnd >>>= 0;
              if (this === target) return 0;
              var x = thisEnd - thisStart;
              var y = end - start;
              var len = Math.min(x, y);
              var thisCopy = this.slice(thisStart, thisEnd);
              var targetCopy = target.slice(start, end);
              for (var i = 0; i < len; ++i) {
                if (thisCopy[i] !== targetCopy[i]) {
                  x = thisCopy[i];
                  y = targetCopy[i];
                  break;
                }
              }
              if (x < y) return -1;
              if (y < x) return 1;
              return 0;
            };
            function bidirectionalIndexOf(
              buffer,
              val,
              byteOffset,
              encoding,
              dir
            ) {
              if (buffer.length === 0) return -1;
              if (typeof byteOffset === "string") {
                encoding = byteOffset;
                byteOffset = 0;
              } else if (byteOffset > 2147483647) {
                byteOffset = 2147483647;
              } else if (byteOffset < -2147483648) {
                byteOffset = -2147483648;
              }
              byteOffset = +byteOffset;
              if (numberIsNaN(byteOffset)) {
                byteOffset = dir ? 0 : buffer.length - 1;
              }
              if (byteOffset < 0) byteOffset = buffer.length + byteOffset;
              if (byteOffset >= buffer.length) {
                if (dir) return -1;
                else byteOffset = buffer.length - 1;
              } else if (byteOffset < 0) {
                if (dir) byteOffset = 0;
                else return -1;
              }
              if (typeof val === "string") {
                val = Buffer.from(val, encoding);
              }
              if (Buffer.isBuffer(val)) {
                if (val.length === 0) {
                  return -1;
                }
                return arrayIndexOf(buffer, val, byteOffset, encoding, dir);
              } else if (typeof val === "number") {
                val = val & 255;
                if (typeof Uint8Array.prototype.indexOf === "function") {
                  if (dir) {
                    return Uint8Array.prototype.indexOf.call(
                      buffer,
                      val,
                      byteOffset
                    );
                  } else {
                    return Uint8Array.prototype.lastIndexOf.call(
                      buffer,
                      val,
                      byteOffset
                    );
                  }
                }
                return arrayIndexOf(buffer, [val], byteOffset, encoding, dir);
              }
              throw new TypeError("val must be string, number or Buffer");
            }
            function arrayIndexOf(arr, val, byteOffset, encoding, dir) {
              var indexSize = 1;
              var arrLength = arr.length;
              var valLength = val.length;
              if (encoding !== undefined) {
                encoding = String(encoding).toLowerCase();
                if (
                  encoding === "ucs2" ||
                  encoding === "ucs-2" ||
                  encoding === "utf16le" ||
                  encoding === "utf-16le"
                ) {
                  if (arr.length < 2 || val.length < 2) {
                    return -1;
                  }
                  indexSize = 2;
                  arrLength /= 2;
                  valLength /= 2;
                  byteOffset /= 2;
                }
              }
              function read(buf, i) {
                if (indexSize === 1) {
                  return buf[i];
                } else {
                  return buf.readUInt16BE(i * indexSize);
                }
              }
              var i;
              if (dir) {
                var foundIndex = -1;
                for (i = byteOffset; i < arrLength; i++) {
                  if (
                    read(arr, i) ===
                    read(val, foundIndex === -1 ? 0 : i - foundIndex)
                  ) {
                    if (foundIndex === -1) foundIndex = i;
                    if (i - foundIndex + 1 === valLength)
                      return foundIndex * indexSize;
                  } else {
                    if (foundIndex !== -1) i -= i - foundIndex;
                    foundIndex = -1;
                  }
                }
              } else {
                if (byteOffset + valLength > arrLength)
                  byteOffset = arrLength - valLength;
                for (i = byteOffset; i >= 0; i--) {
                  var found = true;
                  for (var j = 0; j < valLength; j++) {
                    if (read(arr, i + j) !== read(val, j)) {
                      found = false;
                      break;
                    }
                  }
                  if (found) return i;
                }
              }
              return -1;
            }
            Buffer.prototype.includes = function includes(
              val,
              byteOffset,
              encoding
            ) {
              return this.indexOf(val, byteOffset, encoding) !== -1;
            };
            Buffer.prototype.indexOf = function indexOf(
              val,
              byteOffset,
              encoding
            ) {
              return bidirectionalIndexOf(
                this,
                val,
                byteOffset,
                encoding,
                true
              );
            };
            Buffer.prototype.lastIndexOf = function lastIndexOf(
              val,
              byteOffset,
              encoding
            ) {
              return bidirectionalIndexOf(
                this,
                val,
                byteOffset,
                encoding,
                false
              );
            };
            function hexWrite(buf, string, offset, length) {
              offset = Number(offset) || 0;
              var remaining = buf.length - offset;
              if (!length) {
                length = remaining;
              } else {
                length = Number(length);
                if (length > remaining) {
                  length = remaining;
                }
              }
              var strLen = string.length;
              if (length > strLen / 2) {
                length = strLen / 2;
              }
              for (var i = 0; i < length; ++i) {
                var parsed = parseInt(string.substr(i * 2, 2), 16);
                if (numberIsNaN(parsed)) return i;
                buf[offset + i] = parsed;
              }
              return i;
            }
            function utf8Write(buf, string, offset, length) {
              return blitBuffer(
                utf8ToBytes(string, buf.length - offset),
                buf,
                offset,
                length
              );
            }
            function asciiWrite(buf, string, offset, length) {
              return blitBuffer(asciiToBytes(string), buf, offset, length);
            }
            function latin1Write(buf, string, offset, length) {
              return asciiWrite(buf, string, offset, length);
            }
            function base64Write(buf, string, offset, length) {
              return blitBuffer(base64ToBytes(string), buf, offset, length);
            }
            function ucs2Write(buf, string, offset, length) {
              return blitBuffer(
                utf16leToBytes(string, buf.length - offset),
                buf,
                offset,
                length
              );
            }
            Buffer.prototype.write = function write(
              string,
              offset,
              length,
              encoding
            ) {
              if (offset === undefined) {
                encoding = "utf8";
                length = this.length;
                offset = 0;
              } else if (length === undefined && typeof offset === "string") {
                encoding = offset;
                length = this.length;
                offset = 0;
              } else if (isFinite(offset)) {
                offset = offset >>> 0;
                if (isFinite(length)) {
                  length = length >>> 0;
                  if (encoding === undefined) encoding = "utf8";
                } else {
                  encoding = length;
                  length = undefined;
                }
              } else {
                throw new Error(
                  "Buffer.write(string, encoding, offset[, length]) is no longer supported"
                );
              }
              var remaining = this.length - offset;
              if (length === undefined || length > remaining)
                length = remaining;
              if (
                (string.length > 0 && (length < 0 || offset < 0)) ||
                offset > this.length
              ) {
                throw new RangeError("Attempt to write outside buffer bounds");
              }
              if (!encoding) encoding = "utf8";
              var loweredCase = false;
              for (;;) {
                switch (encoding) {
                  case "hex":
                    return hexWrite(this, string, offset, length);
                  case "utf8":
                  case "utf-8":
                    return utf8Write(this, string, offset, length);
                  case "ascii":
                    return asciiWrite(this, string, offset, length);
                  case "latin1":
                  case "binary":
                    return latin1Write(this, string, offset, length);
                  case "base64":
                    return base64Write(this, string, offset, length);
                  case "ucs2":
                  case "ucs-2":
                  case "utf16le":
                  case "utf-16le":
                    return ucs2Write(this, string, offset, length);
                  default:
                    if (loweredCase)
                      throw new TypeError("Unknown encoding: " + encoding);
                    encoding = ("" + encoding).toLowerCase();
                    loweredCase = true;
                }
              }
            };
            Buffer.prototype.toJSON = function toJSON() {
              return {
                type: "Buffer",
                data: Array.prototype.slice.call(this._arr || this, 0),
              };
            };
            function base64Slice(buf, start, end) {
              if (start === 0 && end === buf.length) {
                return base64.fromByteArray(buf);
              } else {
                return base64.fromByteArray(buf.slice(start, end));
              }
            }
            function utf8Slice(buf, start, end) {
              end = Math.min(buf.length, end);
              var res = [];
              var i = start;
              while (i < end) {
                var firstByte = buf[i];
                var codePoint = null;
                var bytesPerSequence =
                  firstByte > 239
                    ? 4
                    : firstByte > 223
                    ? 3
                    : firstByte > 191
                    ? 2
                    : 1;
                if (i + bytesPerSequence <= end) {
                  var secondByte, thirdByte, fourthByte, tempCodePoint;
                  switch (bytesPerSequence) {
                    case 1:
                      if (firstByte < 128) {
                        codePoint = firstByte;
                      }
                      break;
                    case 2:
                      secondByte = buf[i + 1];
                      if ((secondByte & 192) === 128) {
                        tempCodePoint =
                          ((firstByte & 31) << 6) | (secondByte & 63);
                        if (tempCodePoint > 127) {
                          codePoint = tempCodePoint;
                        }
                      }
                      break;
                    case 3:
                      secondByte = buf[i + 1];
                      thirdByte = buf[i + 2];
                      if (
                        (secondByte & 192) === 128 &&
                        (thirdByte & 192) === 128
                      ) {
                        tempCodePoint =
                          ((firstByte & 15) << 12) |
                          ((secondByte & 63) << 6) |
                          (thirdByte & 63);
                        if (
                          tempCodePoint > 2047 &&
                          (tempCodePoint < 55296 || tempCodePoint > 57343)
                        ) {
                          codePoint = tempCodePoint;
                        }
                      }
                      break;
                    case 4:
                      secondByte = buf[i + 1];
                      thirdByte = buf[i + 2];
                      fourthByte = buf[i + 3];
                      if (
                        (secondByte & 192) === 128 &&
                        (thirdByte & 192) === 128 &&
                        (fourthByte & 192) === 128
                      ) {
                        tempCodePoint =
                          ((firstByte & 15) << 18) |
                          ((secondByte & 63) << 12) |
                          ((thirdByte & 63) << 6) |
                          (fourthByte & 63);
                        if (tempCodePoint > 65535 && tempCodePoint < 1114112) {
                          codePoint = tempCodePoint;
                        }
                      }
                  }
                }
                if (codePoint === null) {
                  codePoint = 65533;
                  bytesPerSequence = 1;
                } else if (codePoint > 65535) {
                  codePoint -= 65536;
                  res.push(((codePoint >>> 10) & 1023) | 55296);
                  codePoint = 56320 | (codePoint & 1023);
                }
                res.push(codePoint);
                i += bytesPerSequence;
              }
              return decodeCodePointsArray(res);
            }
            var MAX_ARGUMENTS_LENGTH = 4096;
            function decodeCodePointsArray(codePoints) {
              var len = codePoints.length;
              if (len <= MAX_ARGUMENTS_LENGTH) {
                return String.fromCharCode.apply(String, codePoints);
              }
              var res = "";
              var i = 0;
              while (i < len) {
                res += String.fromCharCode.apply(
                  String,
                  codePoints.slice(i, (i += MAX_ARGUMENTS_LENGTH))
                );
              }
              return res;
            }
            function asciiSlice(buf, start, end) {
              var ret = "";
              end = Math.min(buf.length, end);
              for (var i = start; i < end; ++i) {
                ret += String.fromCharCode(buf[i] & 127);
              }
              return ret;
            }
            function latin1Slice(buf, start, end) {
              var ret = "";
              end = Math.min(buf.length, end);
              for (var i = start; i < end; ++i) {
                ret += String.fromCharCode(buf[i]);
              }
              return ret;
            }
            function hexSlice(buf, start, end) {
              var len = buf.length;
              if (!start || start < 0) start = 0;
              if (!end || end < 0 || end > len) end = len;
              var out = "";
              for (var i = start; i < end; ++i) {
                out += toHex(buf[i]);
              }
              return out;
            }
            function utf16leSlice(buf, start, end) {
              var bytes = buf.slice(start, end);
              var res = "";
              for (var i = 0; i < bytes.length; i += 2) {
                res += String.fromCharCode(bytes[i] + bytes[i + 1] * 256);
              }
              return res;
            }
            Buffer.prototype.slice = function slice(start, end) {
              var len = this.length;
              start = ~~start;
              end = end === undefined ? len : ~~end;
              if (start < 0) {
                start += len;
                if (start < 0) start = 0;
              } else if (start > len) {
                start = len;
              }
              if (end < 0) {
                end += len;
                if (end < 0) end = 0;
              } else if (end > len) {
                end = len;
              }
              if (end < start) end = start;
              var newBuf = this.subarray(start, end);
              newBuf.__proto__ = Buffer.prototype;
              return newBuf;
            };
            function checkOffset(offset, ext, length) {
              if (offset % 1 !== 0 || offset < 0)
                throw new RangeError("offset is not uint");
              if (offset + ext > length)
                throw new RangeError("Trying to access beyond buffer length");
            }
            Buffer.prototype.readUIntLE = function readUIntLE(
              offset,
              byteLength,
              noAssert
            ) {
              offset = offset >>> 0;
              byteLength = byteLength >>> 0;
              if (!noAssert) checkOffset(offset, byteLength, this.length);
              var val = this[offset];
              var mul = 1;
              var i = 0;
              while (++i < byteLength && (mul *= 256)) {
                val += this[offset + i] * mul;
              }
              return val;
            };
            Buffer.prototype.readUIntBE = function readUIntBE(
              offset,
              byteLength,
              noAssert
            ) {
              offset = offset >>> 0;
              byteLength = byteLength >>> 0;
              if (!noAssert) {
                checkOffset(offset, byteLength, this.length);
              }
              var val = this[offset + --byteLength];
              var mul = 1;
              while (byteLength > 0 && (mul *= 256)) {
                val += this[offset + --byteLength] * mul;
              }
              return val;
            };
            Buffer.prototype.readUInt8 = function readUInt8(offset, noAssert) {
              offset = offset >>> 0;
              if (!noAssert) checkOffset(offset, 1, this.length);
              return this[offset];
            };
            Buffer.prototype.readUInt16LE = function readUInt16LE(
              offset,
              noAssert
            ) {
              offset = offset >>> 0;
              if (!noAssert) checkOffset(offset, 2, this.length);
              return this[offset] | (this[offset + 1] << 8);
            };
            Buffer.prototype.readUInt16BE = function readUInt16BE(
              offset,
              noAssert
            ) {
              offset = offset >>> 0;
              if (!noAssert) checkOffset(offset, 2, this.length);
              return (this[offset] << 8) | this[offset + 1];
            };
            Buffer.prototype.readUInt32LE = function readUInt32LE(
              offset,
              noAssert
            ) {
              offset = offset >>> 0;
              if (!noAssert) checkOffset(offset, 4, this.length);
              return (
                (this[offset] |
                  (this[offset + 1] << 8) |
                  (this[offset + 2] << 16)) +
                this[offset + 3] * 16777216
              );
            };
            Buffer.prototype.readUInt32BE = function readUInt32BE(
              offset,
              noAssert
            ) {
              offset = offset >>> 0;
              if (!noAssert) checkOffset(offset, 4, this.length);
              return (
                this[offset] * 16777216 +
                ((this[offset + 1] << 16) |
                  (this[offset + 2] << 8) |
                  this[offset + 3])
              );
            };
            Buffer.prototype.readIntLE = function readIntLE(
              offset,
              byteLength,
              noAssert
            ) {
              offset = offset >>> 0;
              byteLength = byteLength >>> 0;
              if (!noAssert) checkOffset(offset, byteLength, this.length);
              var val = this[offset];
              var mul = 1;
              var i = 0;
              while (++i < byteLength && (mul *= 256)) {
                val += this[offset + i] * mul;
              }
              mul *= 128;
              if (val >= mul) val -= Math.pow(2, 8 * byteLength);
              return val;
            };
            Buffer.prototype.readIntBE = function readIntBE(
              offset,
              byteLength,
              noAssert
            ) {
              offset = offset >>> 0;
              byteLength = byteLength >>> 0;
              if (!noAssert) checkOffset(offset, byteLength, this.length);
              var i = byteLength;
              var mul = 1;
              var val = this[offset + --i];
              while (i > 0 && (mul *= 256)) {
                val += this[offset + --i] * mul;
              }
              mul *= 128;
              if (val >= mul) val -= Math.pow(2, 8 * byteLength);
              return val;
            };
            Buffer.prototype.readInt8 = function readInt8(offset, noAssert) {
              offset = offset >>> 0;
              if (!noAssert) checkOffset(offset, 1, this.length);
              if (!(this[offset] & 128)) return this[offset];
              return (255 - this[offset] + 1) * -1;
            };
            Buffer.prototype.readInt16LE = function readInt16LE(
              offset,
              noAssert
            ) {
              offset = offset >>> 0;
              if (!noAssert) checkOffset(offset, 2, this.length);
              var val = this[offset] | (this[offset + 1] << 8);
              return val & 32768 ? val | 4294901760 : val;
            };
            Buffer.prototype.readInt16BE = function readInt16BE(
              offset,
              noAssert
            ) {
              offset = offset >>> 0;
              if (!noAssert) checkOffset(offset, 2, this.length);
              var val = this[offset + 1] | (this[offset] << 8);
              return val & 32768 ? val | 4294901760 : val;
            };
            Buffer.prototype.readInt32LE = function readInt32LE(
              offset,
              noAssert
            ) {
              offset = offset >>> 0;
              if (!noAssert) checkOffset(offset, 4, this.length);
              return (
                this[offset] |
                (this[offset + 1] << 8) |
                (this[offset + 2] << 16) |
                (this[offset + 3] << 24)
              );
            };
            Buffer.prototype.readInt32BE = function readInt32BE(
              offset,
              noAssert
            ) {
              offset = offset >>> 0;
              if (!noAssert) checkOffset(offset, 4, this.length);
              return (
                (this[offset] << 24) |
                (this[offset + 1] << 16) |
                (this[offset + 2] << 8) |
                this[offset + 3]
              );
            };
            Buffer.prototype.readFloatLE = function readFloatLE(
              offset,
              noAssert
            ) {
              offset = offset >>> 0;
              if (!noAssert) checkOffset(offset, 4, this.length);
              return ieee754.read(this, offset, true, 23, 4);
            };
            Buffer.prototype.readFloatBE = function readFloatBE(
              offset,
              noAssert
            ) {
              offset = offset >>> 0;
              if (!noAssert) checkOffset(offset, 4, this.length);
              return ieee754.read(this, offset, false, 23, 4);
            };
            Buffer.prototype.readDoubleLE = function readDoubleLE(
              offset,
              noAssert
            ) {
              offset = offset >>> 0;
              if (!noAssert) checkOffset(offset, 8, this.length);
              return ieee754.read(this, offset, true, 52, 8);
            };
            Buffer.prototype.readDoubleBE = function readDoubleBE(
              offset,
              noAssert
            ) {
              offset = offset >>> 0;
              if (!noAssert) checkOffset(offset, 8, this.length);
              return ieee754.read(this, offset, false, 52, 8);
            };
            function checkInt(buf, value, offset, ext, max, min) {
              if (!Buffer.isBuffer(buf))
                throw new TypeError(
                  '"buffer" argument must be a Buffer instance'
                );
              if (value > max || value < min)
                throw new RangeError('"value" argument is out of bounds');
              if (offset + ext > buf.length)
                throw new RangeError("Index out of range");
            }
            Buffer.prototype.writeUIntLE = function writeUIntLE(
              value,
              offset,
              byteLength,
              noAssert
            ) {
              value = +value;
              offset = offset >>> 0;
              byteLength = byteLength >>> 0;
              if (!noAssert) {
                var maxBytes = Math.pow(2, 8 * byteLength) - 1;
                checkInt(this, value, offset, byteLength, maxBytes, 0);
              }
              var mul = 1;
              var i = 0;
              this[offset] = value & 255;
              while (++i < byteLength && (mul *= 256)) {
                this[offset + i] = (value / mul) & 255;
              }
              return offset + byteLength;
            };
            Buffer.prototype.writeUIntBE = function writeUIntBE(
              value,
              offset,
              byteLength,
              noAssert
            ) {
              value = +value;
              offset = offset >>> 0;
              byteLength = byteLength >>> 0;
              if (!noAssert) {
                var maxBytes = Math.pow(2, 8 * byteLength) - 1;
                checkInt(this, value, offset, byteLength, maxBytes, 0);
              }
              var i = byteLength - 1;
              var mul = 1;
              this[offset + i] = value & 255;
              while (--i >= 0 && (mul *= 256)) {
                this[offset + i] = (value / mul) & 255;
              }
              return offset + byteLength;
            };
            Buffer.prototype.writeUInt8 = function writeUInt8(
              value,
              offset,
              noAssert
            ) {
              value = +value;
              offset = offset >>> 0;
              if (!noAssert) checkInt(this, value, offset, 1, 255, 0);
              this[offset] = value & 255;
              return offset + 1;
            };
            Buffer.prototype.writeUInt16LE = function writeUInt16LE(
              value,
              offset,
              noAssert
            ) {
              value = +value;
              offset = offset >>> 0;
              if (!noAssert) checkInt(this, value, offset, 2, 65535, 0);
              this[offset] = value & 255;
              this[offset + 1] = value >>> 8;
              return offset + 2;
            };
            Buffer.prototype.writeUInt16BE = function writeUInt16BE(
              value,
              offset,
              noAssert
            ) {
              value = +value;
              offset = offset >>> 0;
              if (!noAssert) checkInt(this, value, offset, 2, 65535, 0);
              this[offset] = value >>> 8;
              this[offset + 1] = value & 255;
              return offset + 2;
            };
            Buffer.prototype.writeUInt32LE = function writeUInt32LE(
              value,
              offset,
              noAssert
            ) {
              value = +value;
              offset = offset >>> 0;
              if (!noAssert) checkInt(this, value, offset, 4, 4294967295, 0);
              this[offset + 3] = value >>> 24;
              this[offset + 2] = value >>> 16;
              this[offset + 1] = value >>> 8;
              this[offset] = value & 255;
              return offset + 4;
            };
            Buffer.prototype.writeUInt32BE = function writeUInt32BE(
              value,
              offset,
              noAssert
            ) {
              value = +value;
              offset = offset >>> 0;
              if (!noAssert) checkInt(this, value, offset, 4, 4294967295, 0);
              this[offset] = value >>> 24;
              this[offset + 1] = value >>> 16;
              this[offset + 2] = value >>> 8;
              this[offset + 3] = value & 255;
              return offset + 4;
            };
            Buffer.prototype.writeIntLE = function writeIntLE(
              value,
              offset,
              byteLength,
              noAssert
            ) {
              value = +value;
              offset = offset >>> 0;
              if (!noAssert) {
                var limit = Math.pow(2, 8 * byteLength - 1);
                checkInt(this, value, offset, byteLength, limit - 1, -limit);
              }
              var i = 0;
              var mul = 1;
              var sub = 0;
              this[offset] = value & 255;
              while (++i < byteLength && (mul *= 256)) {
                if (value < 0 && sub === 0 && this[offset + i - 1] !== 0) {
                  sub = 1;
                }
                this[offset + i] = (((value / mul) >> 0) - sub) & 255;
              }
              return offset + byteLength;
            };
            Buffer.prototype.writeIntBE = function writeIntBE(
              value,
              offset,
              byteLength,
              noAssert
            ) {
              value = +value;
              offset = offset >>> 0;
              if (!noAssert) {
                var limit = Math.pow(2, 8 * byteLength - 1);
                checkInt(this, value, offset, byteLength, limit - 1, -limit);
              }
              var i = byteLength - 1;
              var mul = 1;
              var sub = 0;
              this[offset + i] = value & 255;
              while (--i >= 0 && (mul *= 256)) {
                if (value < 0 && sub === 0 && this[offset + i + 1] !== 0) {
                  sub = 1;
                }
                this[offset + i] = (((value / mul) >> 0) - sub) & 255;
              }
              return offset + byteLength;
            };
            Buffer.prototype.writeInt8 = function writeInt8(
              value,
              offset,
              noAssert
            ) {
              value = +value;
              offset = offset >>> 0;
              if (!noAssert) checkInt(this, value, offset, 1, 127, -128);
              if (value < 0) value = 255 + value + 1;
              this[offset] = value & 255;
              return offset + 1;
            };
            Buffer.prototype.writeInt16LE = function writeInt16LE(
              value,
              offset,
              noAssert
            ) {
              value = +value;
              offset = offset >>> 0;
              if (!noAssert) checkInt(this, value, offset, 2, 32767, -32768);
              this[offset] = value & 255;
              this[offset + 1] = value >>> 8;
              return offset + 2;
            };
            Buffer.prototype.writeInt16BE = function writeInt16BE(
              value,
              offset,
              noAssert
            ) {
              value = +value;
              offset = offset >>> 0;
              if (!noAssert) checkInt(this, value, offset, 2, 32767, -32768);
              this[offset] = value >>> 8;
              this[offset + 1] = value & 255;
              return offset + 2;
            };
            Buffer.prototype.writeInt32LE = function writeInt32LE(
              value,
              offset,
              noAssert
            ) {
              value = +value;
              offset = offset >>> 0;
              if (!noAssert)
                checkInt(this, value, offset, 4, 2147483647, -2147483648);
              this[offset] = value & 255;
              this[offset + 1] = value >>> 8;
              this[offset + 2] = value >>> 16;
              this[offset + 3] = value >>> 24;
              return offset + 4;
            };
            Buffer.prototype.writeInt32BE = function writeInt32BE(
              value,
              offset,
              noAssert
            ) {
              value = +value;
              offset = offset >>> 0;
              if (!noAssert)
                checkInt(this, value, offset, 4, 2147483647, -2147483648);
              if (value < 0) value = 4294967295 + value + 1;
              this[offset] = value >>> 24;
              this[offset + 1] = value >>> 16;
              this[offset + 2] = value >>> 8;
              this[offset + 3] = value & 255;
              return offset + 4;
            };
            function checkIEEE754(buf, value, offset, ext, max, min) {
              if (offset + ext > buf.length)
                throw new RangeError("Index out of range");
              if (offset < 0) throw new RangeError("Index out of range");
            }
            function writeFloat(buf, value, offset, littleEndian, noAssert) {
              value = +value;
              offset = offset >>> 0;
              if (!noAssert) {
                checkIEEE754(
                  buf,
                  value,
                  offset,
                  4,
                  34028234663852886e22,
                  -34028234663852886e22
                );
              }
              ieee754.write(buf, value, offset, littleEndian, 23, 4);
              return offset + 4;
            }
            Buffer.prototype.writeFloatLE = function writeFloatLE(
              value,
              offset,
              noAssert
            ) {
              return writeFloat(this, value, offset, true, noAssert);
            };
            Buffer.prototype.writeFloatBE = function writeFloatBE(
              value,
              offset,
              noAssert
            ) {
              return writeFloat(this, value, offset, false, noAssert);
            };
            function writeDouble(buf, value, offset, littleEndian, noAssert) {
              value = +value;
              offset = offset >>> 0;
              if (!noAssert) {
                checkIEEE754(
                  buf,
                  value,
                  offset,
                  8,
                  17976931348623157e292,
                  -17976931348623157e292
                );
              }
              ieee754.write(buf, value, offset, littleEndian, 52, 8);
              return offset + 8;
            }
            Buffer.prototype.writeDoubleLE = function writeDoubleLE(
              value,
              offset,
              noAssert
            ) {
              return writeDouble(this, value, offset, true, noAssert);
            };
            Buffer.prototype.writeDoubleBE = function writeDoubleBE(
              value,
              offset,
              noAssert
            ) {
              return writeDouble(this, value, offset, false, noAssert);
            };
            Buffer.prototype.copy = function copy(
              target,
              targetStart,
              start,
              end
            ) {
              if (!Buffer.isBuffer(target))
                throw new TypeError("argument should be a Buffer");
              if (!start) start = 0;
              if (!end && end !== 0) end = this.length;
              if (targetStart >= target.length) targetStart = target.length;
              if (!targetStart) targetStart = 0;
              if (end > 0 && end < start) end = start;
              if (end === start) return 0;
              if (target.length === 0 || this.length === 0) return 0;
              if (targetStart < 0) {
                throw new RangeError("targetStart out of bounds");
              }
              if (start < 0 || start >= this.length)
                throw new RangeError("Index out of range");
              if (end < 0) throw new RangeError("sourceEnd out of bounds");
              if (end > this.length) end = this.length;
              if (target.length - targetStart < end - start) {
                end = target.length - targetStart + start;
              }
              var len = end - start;
              if (
                this === target &&
                typeof Uint8Array.prototype.copyWithin === "function"
              ) {
                this.copyWithin(targetStart, start, end);
              } else if (
                this === target &&
                start < targetStart &&
                targetStart < end
              ) {
                for (var i = len - 1; i >= 0; --i) {
                  target[i + targetStart] = this[i + start];
                }
              } else {
                Uint8Array.prototype.set.call(
                  target,
                  this.subarray(start, end),
                  targetStart
                );
              }
              return len;
            };
            Buffer.prototype.fill = function fill(val, start, end, encoding) {
              if (typeof val === "string") {
                if (typeof start === "string") {
                  encoding = start;
                  start = 0;
                  end = this.length;
                } else if (typeof end === "string") {
                  encoding = end;
                  end = this.length;
                }
                if (encoding !== undefined && typeof encoding !== "string") {
                  throw new TypeError("encoding must be a string");
                }
                if (
                  typeof encoding === "string" &&
                  !Buffer.isEncoding(encoding)
                ) {
                  throw new TypeError("Unknown encoding: " + encoding);
                }
                if (val.length === 1) {
                  var code = val.charCodeAt(0);
                  if (
                    (encoding === "utf8" && code < 128) ||
                    encoding === "latin1"
                  ) {
                    val = code;
                  }
                }
              } else if (typeof val === "number") {
                val = val & 255;
              }
              if (start < 0 || this.length < start || this.length < end) {
                throw new RangeError("Out of range index");
              }
              if (end <= start) {
                return this;
              }
              start = start >>> 0;
              end = end === undefined ? this.length : end >>> 0;
              if (!val) val = 0;
              var i;
              if (typeof val === "number") {
                for (i = start; i < end; ++i) {
                  this[i] = val;
                }
              } else {
                var bytes = Buffer.isBuffer(val)
                  ? val
                  : Buffer.from(val, encoding);
                var len = bytes.length;
                if (len === 0) {
                  throw new TypeError(
                    'The value "' + val + '" is invalid for argument "value"'
                  );
                }
                for (i = 0; i < end - start; ++i) {
                  this[i + start] = bytes[i % len];
                }
              }
              return this;
            };
            var INVALID_BASE64_RE = /[^+/0-9A-Za-z-_]/g;
            function base64clean(str) {
              str = str.split("=")[0];
              str = str.trim().replace(INVALID_BASE64_RE, "");
              if (str.length < 2) return "";
              while (str.length % 4 !== 0) {
                str = str + "=";
              }
              return str;
            }
            function toHex(n) {
              if (n < 16) return "0" + n.toString(16);
              return n.toString(16);
            }
            function utf8ToBytes(string, units) {
              units = units || Infinity;
              var codePoint;
              var length = string.length;
              var leadSurrogate = null;
              var bytes = [];
              for (var i = 0; i < length; ++i) {
                codePoint = string.charCodeAt(i);
                if (codePoint > 55295 && codePoint < 57344) {
                  if (!leadSurrogate) {
                    if (codePoint > 56319) {
                      if ((units -= 3) > -1) bytes.push(239, 191, 189);
                      continue;
                    } else if (i + 1 === length) {
                      if ((units -= 3) > -1) bytes.push(239, 191, 189);
                      continue;
                    }
                    leadSurrogate = codePoint;
                    continue;
                  }
                  if (codePoint < 56320) {
                    if ((units -= 3) > -1) bytes.push(239, 191, 189);
                    leadSurrogate = codePoint;
                    continue;
                  }
                  codePoint =
                    (((leadSurrogate - 55296) << 10) | (codePoint - 56320)) +
                    65536;
                } else if (leadSurrogate) {
                  if ((units -= 3) > -1) bytes.push(239, 191, 189);
                }
                leadSurrogate = null;
                if (codePoint < 128) {
                  if ((units -= 1) < 0) break;
                  bytes.push(codePoint);
                } else if (codePoint < 2048) {
                  if ((units -= 2) < 0) break;
                  bytes.push((codePoint >> 6) | 192, (codePoint & 63) | 128);
                } else if (codePoint < 65536) {
                  if ((units -= 3) < 0) break;
                  bytes.push(
                    (codePoint >> 12) | 224,
                    ((codePoint >> 6) & 63) | 128,
                    (codePoint & 63) | 128
                  );
                } else if (codePoint < 1114112) {
                  if ((units -= 4) < 0) break;
                  bytes.push(
                    (codePoint >> 18) | 240,
                    ((codePoint >> 12) & 63) | 128,
                    ((codePoint >> 6) & 63) | 128,
                    (codePoint & 63) | 128
                  );
                } else {
                  throw new Error("Invalid code point");
                }
              }
              return bytes;
            }
            function asciiToBytes(str) {
              var byteArray = [];
              for (var i = 0; i < str.length; ++i) {
                byteArray.push(str.charCodeAt(i) & 255);
              }
              return byteArray;
            }
            function utf16leToBytes(str, units) {
              var c, hi, lo;
              var byteArray = [];
              for (var i = 0; i < str.length; ++i) {
                if ((units -= 2) < 0) break;
                c = str.charCodeAt(i);
                hi = c >> 8;
                lo = c % 256;
                byteArray.push(lo);
                byteArray.push(hi);
              }
              return byteArray;
            }
            function base64ToBytes(str) {
              return base64.toByteArray(base64clean(str));
            }
            function blitBuffer(src, dst, offset, length) {
              for (var i = 0; i < length; ++i) {
                if (i + offset >= dst.length || i >= src.length) break;
                dst[i + offset] = src[i];
              }
              return i;
            }
            function isInstance(obj, type) {
              return (
                obj instanceof type ||
                (obj != null &&
                  obj.constructor != null &&
                  obj.constructor.name != null &&
                  obj.constructor.name === type.name)
              );
            }
            function numberIsNaN(obj) {
              return obj !== obj;
            }
          }).call(this);
        }).call(this, require("buffer").Buffer);
      },
      { "base64-js": 21, buffer: 25, ieee754: 93 },
    ],
    26: [
      function (require, module, exports) {
        var Buffer = require("safe-buffer").Buffer;
        var Transform = require("stream").Transform;
        var StringDecoder = require("string_decoder").StringDecoder;
        var inherits = require("inherits");
        function CipherBase(hashMode) {
          Transform.call(this);
          this.hashMode = typeof hashMode === "string";
          if (this.hashMode) {
            this[hashMode] = this._finalOrDigest;
          } else {
            this.final = this._finalOrDigest;
          }
          if (this._final) {
            this.__final = this._final;
            this._final = null;
          }
          this._decoder = null;
          this._encoding = null;
        }
        inherits(CipherBase, Transform);
        CipherBase.prototype.update = function (data, inputEnc, outputEnc) {
          if (typeof data === "string") {
            data = Buffer.from(data, inputEnc);
          }
          var outData = this._update(data);
          if (this.hashMode) return this;
          if (outputEnc) {
            outData = this._toString(outData, outputEnc);
          }
          return outData;
        };
        CipherBase.prototype.setAutoPadding = function () {};
        CipherBase.prototype.getAuthTag = function () {
          throw new Error("trying to get auth tag in unsupported state");
        };
        CipherBase.prototype.setAuthTag = function () {
          throw new Error("trying to set auth tag in unsupported state");
        };
        CipherBase.prototype.setAAD = function () {
          throw new Error("trying to set aad in unsupported state");
        };
        CipherBase.prototype._transform = function (data, _, next) {
          var err;
          try {
            if (this.hashMode) {
              this._update(data);
            } else {
              this.push(this._update(data));
            }
          } catch (e) {
            err = e;
          } finally {
            next(err);
          }
        };
        CipherBase.prototype._flush = function (done) {
          var err;
          try {
            this.push(this.__final());
          } catch (e) {
            err = e;
          }
          done(err);
        };
        CipherBase.prototype._finalOrDigest = function (outputEnc) {
          var outData = this.__final() || Buffer.alloc(0);
          if (outputEnc) {
            outData = this._toString(outData, outputEnc, true);
          }
          return outData;
        };
        CipherBase.prototype._toString = function (value, enc, fin) {
          if (!this._decoder) {
            this._decoder = new StringDecoder(enc);
            this._encoding = enc;
          }
          if (this._encoding !== enc) throw new Error("can't switch encodings");
          var out = this._decoder.write(value);
          if (fin) {
            out += this._decoder.end();
          }
          return out;
        };
        module.exports = CipherBase;
      },
      { inherits: 94, "safe-buffer": 126, stream: 138, string_decoder: 153 },
    ],
    27: [
      function (require, module, exports) {
        "use strict";
        var inherits = require("inherits");
        var MD5 = require("md5.js");
        var RIPEMD160 = require("ripemd160");
        var sha = require("sha.js");
        var Base = require("cipher-base");
        function Hash(hash) {
          Base.call(this, "digest");
          this._hash = hash;
        }
        inherits(Hash, Base);
        Hash.prototype._update = function (data) {
          this._hash.update(data);
        };
        Hash.prototype._final = function () {
          return this._hash.digest();
        };
        module.exports = function createHash(alg) {
          alg = alg.toLowerCase();
          if (alg === "md5") return new MD5();
          if (alg === "rmd160" || alg === "ripemd160") return new RIPEMD160();
          return new Hash(sha(alg));
        };
      },
      {
        "cipher-base": 26,
        inherits: 94,
        "md5.js": 118,
        ripemd160: 124,
        "sha.js": 131,
      },
    ],
    28: [
      function (require, module, exports) {
        "use strict";
        var elliptic = exports;
        elliptic.version = require("../package.json").version;
        elliptic.utils = require("./elliptic/utils");
        elliptic.rand = require("brorand");
        elliptic.curve = require("./elliptic/curve");
        elliptic.curves = require("./elliptic/curves");
        elliptic.ec = require("./elliptic/ec");
        elliptic.eddsa = require("./elliptic/eddsa");
      },
      {
        "../package.json": 44,
        "./elliptic/curve": 31,
        "./elliptic/curves": 34,
        "./elliptic/ec": 35,
        "./elliptic/eddsa": 38,
        "./elliptic/utils": 42,
        brorand: 23,
      },
    ],
    29: [
      function (require, module, exports) {
        "use strict";
        var BN = require("bn.js");
        var utils = require("../utils");
        var getNAF = utils.getNAF;
        var getJSF = utils.getJSF;
        var assert = utils.assert;
        function BaseCurve(type, conf) {
          this.type = type;
          this.p = new BN(conf.p, 16);
          this.red = conf.prime ? BN.red(conf.prime) : BN.mont(this.p);
          this.zero = new BN(0).toRed(this.red);
          this.one = new BN(1).toRed(this.red);
          this.two = new BN(2).toRed(this.red);
          this.n = conf.n && new BN(conf.n, 16);
          this.g = conf.g && this.pointFromJSON(conf.g, conf.gRed);
          this._wnafT1 = new Array(4);
          this._wnafT2 = new Array(4);
          this._wnafT3 = new Array(4);
          this._wnafT4 = new Array(4);
          this._bitLength = this.n ? this.n.bitLength() : 0;
          var adjustCount = this.n && this.p.div(this.n);
          if (!adjustCount || adjustCount.cmpn(100) > 0) {
            this.redN = null;
          } else {
            this._maxwellTrick = true;
            this.redN = this.n.toRed(this.red);
          }
        }
        module.exports = BaseCurve;
        BaseCurve.prototype.point = function point() {
          throw new Error("Not implemented");
        };
        BaseCurve.prototype.validate = function validate() {
          throw new Error("Not implemented");
        };
        BaseCurve.prototype._fixedNafMul = function _fixedNafMul(p, k) {
          assert(p.precomputed);
          var doubles = p._getDoubles();
          var naf = getNAF(k, 1, this._bitLength);
          var I = (1 << (doubles.step + 1)) - (doubles.step % 2 === 0 ? 2 : 1);
          I /= 3;
          var repr = [];
          var j;
          var nafW;
          for (j = 0; j < naf.length; j += doubles.step) {
            nafW = 0;
            for (var l = j + doubles.step - 1; l >= j; l--)
              nafW = (nafW << 1) + naf[l];
            repr.push(nafW);
          }
          var a = this.jpoint(null, null, null);
          var b = this.jpoint(null, null, null);
          for (var i = I; i > 0; i--) {
            for (j = 0; j < repr.length; j++) {
              nafW = repr[j];
              if (nafW === i) b = b.mixedAdd(doubles.points[j]);
              else if (nafW === -i) b = b.mixedAdd(doubles.points[j].neg());
            }
            a = a.add(b);
          }
          return a.toP();
        };
        BaseCurve.prototype._wnafMul = function _wnafMul(p, k) {
          var w = 4;
          var nafPoints = p._getNAFPoints(w);
          w = nafPoints.wnd;
          var wnd = nafPoints.points;
          var naf = getNAF(k, w, this._bitLength);
          var acc = this.jpoint(null, null, null);
          for (var i = naf.length - 1; i >= 0; i--) {
            for (var l = 0; i >= 0 && naf[i] === 0; i--) l++;
            if (i >= 0) l++;
            acc = acc.dblp(l);
            if (i < 0) break;
            var z = naf[i];
            assert(z !== 0);
            if (p.type === "affine") {
              if (z > 0) acc = acc.mixedAdd(wnd[(z - 1) >> 1]);
              else acc = acc.mixedAdd(wnd[(-z - 1) >> 1].neg());
            } else {
              if (z > 0) acc = acc.add(wnd[(z - 1) >> 1]);
              else acc = acc.add(wnd[(-z - 1) >> 1].neg());
            }
          }
          return p.type === "affine" ? acc.toP() : acc;
        };
        BaseCurve.prototype._wnafMulAdd = function _wnafMulAdd(
          defW,
          points,
          coeffs,
          len,
          jacobianResult
        ) {
          var wndWidth = this._wnafT1;
          var wnd = this._wnafT2;
          var naf = this._wnafT3;
          var max = 0;
          var i;
          var j;
          var p;
          for (i = 0; i < len; i++) {
            p = points[i];
            var nafPoints = p._getNAFPoints(defW);
            wndWidth[i] = nafPoints.wnd;
            wnd[i] = nafPoints.points;
          }
          for (i = len - 1; i >= 1; i -= 2) {
            var a = i - 1;
            var b = i;
            if (wndWidth[a] !== 1 || wndWidth[b] !== 1) {
              naf[a] = getNAF(coeffs[a], wndWidth[a], this._bitLength);
              naf[b] = getNAF(coeffs[b], wndWidth[b], this._bitLength);
              max = Math.max(naf[a].length, max);
              max = Math.max(naf[b].length, max);
              continue;
            }
            var comb = [points[a], null, null, points[b]];
            if (points[a].y.cmp(points[b].y) === 0) {
              comb[1] = points[a].add(points[b]);
              comb[2] = points[a].toJ().mixedAdd(points[b].neg());
            } else if (points[a].y.cmp(points[b].y.redNeg()) === 0) {
              comb[1] = points[a].toJ().mixedAdd(points[b]);
              comb[2] = points[a].add(points[b].neg());
            } else {
              comb[1] = points[a].toJ().mixedAdd(points[b]);
              comb[2] = points[a].toJ().mixedAdd(points[b].neg());
            }
            var index = [-3, -1, -5, -7, 0, 7, 5, 1, 3];
            var jsf = getJSF(coeffs[a], coeffs[b]);
            max = Math.max(jsf[0].length, max);
            naf[a] = new Array(max);
            naf[b] = new Array(max);
            for (j = 0; j < max; j++) {
              var ja = jsf[0][j] | 0;
              var jb = jsf[1][j] | 0;
              naf[a][j] = index[(ja + 1) * 3 + (jb + 1)];
              naf[b][j] = 0;
              wnd[a] = comb;
            }
          }
          var acc = this.jpoint(null, null, null);
          var tmp = this._wnafT4;
          for (i = max; i >= 0; i--) {
            var k = 0;
            while (i >= 0) {
              var zero = true;
              for (j = 0; j < len; j++) {
                tmp[j] = naf[j][i] | 0;
                if (tmp[j] !== 0) zero = false;
              }
              if (!zero) break;
              k++;
              i--;
            }
            if (i >= 0) k++;
            acc = acc.dblp(k);
            if (i < 0) break;
            for (j = 0; j < len; j++) {
              var z = tmp[j];
              p;
              if (z === 0) continue;
              else if (z > 0) p = wnd[j][(z - 1) >> 1];
              else if (z < 0) p = wnd[j][(-z - 1) >> 1].neg();
              if (p.type === "affine") acc = acc.mixedAdd(p);
              else acc = acc.add(p);
            }
          }
          for (i = 0; i < len; i++) wnd[i] = null;
          if (jacobianResult) return acc;
          else return acc.toP();
        };
        function BasePoint(curve, type) {
          this.curve = curve;
          this.type = type;
          this.precomputed = null;
        }
        BaseCurve.BasePoint = BasePoint;
        BasePoint.prototype.eq = function eq() {
          throw new Error("Not implemented");
        };
        BasePoint.prototype.validate = function validate() {
          return this.curve.validate(this);
        };
        BaseCurve.prototype.decodePoint = function decodePoint(bytes, enc) {
          bytes = utils.toArray(bytes, enc);
          var len = this.p.byteLength();
          if (
            (bytes[0] === 4 || bytes[0] === 6 || bytes[0] === 7) &&
            bytes.length - 1 === 2 * len
          ) {
            if (bytes[0] === 6) assert(bytes[bytes.length - 1] % 2 === 0);
            else if (bytes[0] === 7) assert(bytes[bytes.length - 1] % 2 === 1);
            var res = this.point(
              bytes.slice(1, 1 + len),
              bytes.slice(1 + len, 1 + 2 * len)
            );
            return res;
          } else if (
            (bytes[0] === 2 || bytes[0] === 3) &&
            bytes.length - 1 === len
          ) {
            return this.pointFromX(bytes.slice(1, 1 + len), bytes[0] === 3);
          }
          throw new Error("Unknown point format");
        };
        BasePoint.prototype.encodeCompressed = function encodeCompressed(enc) {
          return this.encode(enc, true);
        };
        BasePoint.prototype._encode = function _encode(compact) {
          var len = this.curve.p.byteLength();
          var x = this.getX().toArray("be", len);
          if (compact) return [this.getY().isEven() ? 2 : 3].concat(x);
          return [4].concat(x, this.getY().toArray("be", len));
        };
        BasePoint.prototype.encode = function encode(enc, compact) {
          return utils.encode(this._encode(compact), enc);
        };
        BasePoint.prototype.precompute = function precompute(power) {
          if (this.precomputed) return this;
          var precomputed = { doubles: null, naf: null, beta: null };
          precomputed.naf = this._getNAFPoints(8);
          precomputed.doubles = this._getDoubles(4, power);
          precomputed.beta = this._getBeta();
          this.precomputed = precomputed;
          return this;
        };
        BasePoint.prototype._hasDoubles = function _hasDoubles(k) {
          if (!this.precomputed) return false;
          var doubles = this.precomputed.doubles;
          if (!doubles) return false;
          return (
            doubles.points.length >=
            Math.ceil((k.bitLength() + 1) / doubles.step)
          );
        };
        BasePoint.prototype._getDoubles = function _getDoubles(step, power) {
          if (this.precomputed && this.precomputed.doubles)
            return this.precomputed.doubles;
          var doubles = [this];
          var acc = this;
          for (var i = 0; i < power; i += step) {
            for (var j = 0; j < step; j++) acc = acc.dbl();
            doubles.push(acc);
          }
          return { step: step, points: doubles };
        };
        BasePoint.prototype._getNAFPoints = function _getNAFPoints(wnd) {
          if (this.precomputed && this.precomputed.naf)
            return this.precomputed.naf;
          var res = [this];
          var max = (1 << wnd) - 1;
          var dbl = max === 1 ? null : this.dbl();
          for (var i = 1; i < max; i++) res[i] = res[i - 1].add(dbl);
          return { wnd: wnd, points: res };
        };
        BasePoint.prototype._getBeta = function _getBeta() {
          return null;
        };
        BasePoint.prototype.dblp = function dblp(k) {
          var r = this;
          for (var i = 0; i < k; i++) r = r.dbl();
          return r;
        };
      },
      { "../utils": 42, "bn.js": 43 },
    ],
    30: [
      function (require, module, exports) {
        "use strict";
        var utils = require("../utils");
        var BN = require("bn.js");
        var inherits = require("inherits");
        var Base = require("./base");
        var assert = utils.assert;
        function EdwardsCurve(conf) {
          this.twisted = (conf.a | 0) !== 1;
          this.mOneA = this.twisted && (conf.a | 0) === -1;
          this.extended = this.mOneA;
          Base.call(this, "edwards", conf);
          this.a = new BN(conf.a, 16).umod(this.red.m);
          this.a = this.a.toRed(this.red);
          this.c = new BN(conf.c, 16).toRed(this.red);
          this.c2 = this.c.redSqr();
          this.d = new BN(conf.d, 16).toRed(this.red);
          this.dd = this.d.redAdd(this.d);
          assert(!this.twisted || this.c.fromRed().cmpn(1) === 0);
          this.oneC = (conf.c | 0) === 1;
        }
        inherits(EdwardsCurve, Base);
        module.exports = EdwardsCurve;
        EdwardsCurve.prototype._mulA = function _mulA(num) {
          if (this.mOneA) return num.redNeg();
          else return this.a.redMul(num);
        };
        EdwardsCurve.prototype._mulC = function _mulC(num) {
          if (this.oneC) return num;
          else return this.c.redMul(num);
        };
        EdwardsCurve.prototype.jpoint = function jpoint(x, y, z, t) {
          return this.point(x, y, z, t);
        };
        EdwardsCurve.prototype.pointFromX = function pointFromX(x, odd) {
          x = new BN(x, 16);
          if (!x.red) x = x.toRed(this.red);
          var x2 = x.redSqr();
          var rhs = this.c2.redSub(this.a.redMul(x2));
          var lhs = this.one.redSub(this.c2.redMul(this.d).redMul(x2));
          var y2 = rhs.redMul(lhs.redInvm());
          var y = y2.redSqrt();
          if (y.redSqr().redSub(y2).cmp(this.zero) !== 0)
            throw new Error("invalid point");
          var isOdd = y.fromRed().isOdd();
          if ((odd && !isOdd) || (!odd && isOdd)) y = y.redNeg();
          return this.point(x, y);
        };
        EdwardsCurve.prototype.pointFromY = function pointFromY(y, odd) {
          y = new BN(y, 16);
          if (!y.red) y = y.toRed(this.red);
          var y2 = y.redSqr();
          var lhs = y2.redSub(this.c2);
          var rhs = y2.redMul(this.d).redMul(this.c2).redSub(this.a);
          var x2 = lhs.redMul(rhs.redInvm());
          if (x2.cmp(this.zero) === 0) {
            if (odd) throw new Error("invalid point");
            else return this.point(this.zero, y);
          }
          var x = x2.redSqrt();
          if (x.redSqr().redSub(x2).cmp(this.zero) !== 0)
            throw new Error("invalid point");
          if (x.fromRed().isOdd() !== odd) x = x.redNeg();
          return this.point(x, y);
        };
        EdwardsCurve.prototype.validate = function validate(point) {
          if (point.isInfinity()) return true;
          point.normalize();
          var x2 = point.x.redSqr();
          var y2 = point.y.redSqr();
          var lhs = x2.redMul(this.a).redAdd(y2);
          var rhs = this.c2.redMul(
            this.one.redAdd(this.d.redMul(x2).redMul(y2))
          );
          return lhs.cmp(rhs) === 0;
        };
        function Point(curve, x, y, z, t) {
          Base.BasePoint.call(this, curve, "projective");
          if (x === null && y === null && z === null) {
            this.x = this.curve.zero;
            this.y = this.curve.one;
            this.z = this.curve.one;
            this.t = this.curve.zero;
            this.zOne = true;
          } else {
            this.x = new BN(x, 16);
            this.y = new BN(y, 16);
            this.z = z ? new BN(z, 16) : this.curve.one;
            this.t = t && new BN(t, 16);
            if (!this.x.red) this.x = this.x.toRed(this.curve.red);
            if (!this.y.red) this.y = this.y.toRed(this.curve.red);
            if (!this.z.red) this.z = this.z.toRed(this.curve.red);
            if (this.t && !this.t.red) this.t = this.t.toRed(this.curve.red);
            this.zOne = this.z === this.curve.one;
            if (this.curve.extended && !this.t) {
              this.t = this.x.redMul(this.y);
              if (!this.zOne) this.t = this.t.redMul(this.z.redInvm());
            }
          }
        }
        inherits(Point, Base.BasePoint);
        EdwardsCurve.prototype.pointFromJSON = function pointFromJSON(obj) {
          return Point.fromJSON(this, obj);
        };
        EdwardsCurve.prototype.point = function point(x, y, z, t) {
          return new Point(this, x, y, z, t);
        };
        Point.fromJSON = function fromJSON(curve, obj) {
          return new Point(curve, obj[0], obj[1], obj[2]);
        };
        Point.prototype.inspect = function inspect() {
          if (this.isInfinity()) return "<EC Point Infinity>";
          return (
            "<EC Point x: " +
            this.x.fromRed().toString(16, 2) +
            " y: " +
            this.y.fromRed().toString(16, 2) +
            " z: " +
            this.z.fromRed().toString(16, 2) +
            ">"
          );
        };
        Point.prototype.isInfinity = function isInfinity() {
          return (
            this.x.cmpn(0) === 0 &&
            (this.y.cmp(this.z) === 0 ||
              (this.zOne && this.y.cmp(this.curve.c) === 0))
          );
        };
        Point.prototype._extDbl = function _extDbl() {
          var a = this.x.redSqr();
          var b = this.y.redSqr();
          var c = this.z.redSqr();
          c = c.redIAdd(c);
          var d = this.curve._mulA(a);
          var e = this.x.redAdd(this.y).redSqr().redISub(a).redISub(b);
          var g = d.redAdd(b);
          var f = g.redSub(c);
          var h = d.redSub(b);
          var nx = e.redMul(f);
          var ny = g.redMul(h);
          var nt = e.redMul(h);
          var nz = f.redMul(g);
          return this.curve.point(nx, ny, nz, nt);
        };
        Point.prototype._projDbl = function _projDbl() {
          var b = this.x.redAdd(this.y).redSqr();
          var c = this.x.redSqr();
          var d = this.y.redSqr();
          var nx;
          var ny;
          var nz;
          var e;
          var h;
          var j;
          if (this.curve.twisted) {
            e = this.curve._mulA(c);
            var f = e.redAdd(d);
            if (this.zOne) {
              nx = b.redSub(c).redSub(d).redMul(f.redSub(this.curve.two));
              ny = f.redMul(e.redSub(d));
              nz = f.redSqr().redSub(f).redSub(f);
            } else {
              h = this.z.redSqr();
              j = f.redSub(h).redISub(h);
              nx = b.redSub(c).redISub(d).redMul(j);
              ny = f.redMul(e.redSub(d));
              nz = f.redMul(j);
            }
          } else {
            e = c.redAdd(d);
            h = this.curve._mulC(this.z).redSqr();
            j = e.redSub(h).redSub(h);
            nx = this.curve._mulC(b.redISub(e)).redMul(j);
            ny = this.curve._mulC(e).redMul(c.redISub(d));
            nz = e.redMul(j);
          }
          return this.curve.point(nx, ny, nz);
        };
        Point.prototype.dbl = function dbl() {
          if (this.isInfinity()) return this;
          if (this.curve.extended) return this._extDbl();
          else return this._projDbl();
        };
        Point.prototype._extAdd = function _extAdd(p) {
          var a = this.y.redSub(this.x).redMul(p.y.redSub(p.x));
          var b = this.y.redAdd(this.x).redMul(p.y.redAdd(p.x));
          var c = this.t.redMul(this.curve.dd).redMul(p.t);
          var d = this.z.redMul(p.z.redAdd(p.z));
          var e = b.redSub(a);
          var f = d.redSub(c);
          var g = d.redAdd(c);
          var h = b.redAdd(a);
          var nx = e.redMul(f);
          var ny = g.redMul(h);
          var nt = e.redMul(h);
          var nz = f.redMul(g);
          return this.curve.point(nx, ny, nz, nt);
        };
        Point.prototype._projAdd = function _projAdd(p) {
          var a = this.z.redMul(p.z);
          var b = a.redSqr();
          var c = this.x.redMul(p.x);
          var d = this.y.redMul(p.y);
          var e = this.curve.d.redMul(c).redMul(d);
          var f = b.redSub(e);
          var g = b.redAdd(e);
          var tmp = this.x
            .redAdd(this.y)
            .redMul(p.x.redAdd(p.y))
            .redISub(c)
            .redISub(d);
          var nx = a.redMul(f).redMul(tmp);
          var ny;
          var nz;
          if (this.curve.twisted) {
            ny = a.redMul(g).redMul(d.redSub(this.curve._mulA(c)));
            nz = f.redMul(g);
          } else {
            ny = a.redMul(g).redMul(d.redSub(c));
            nz = this.curve._mulC(f).redMul(g);
          }
          return this.curve.point(nx, ny, nz);
        };
        Point.prototype.add = function add(p) {
          if (this.isInfinity()) return p;
          if (p.isInfinity()) return this;
          if (this.curve.extended) return this._extAdd(p);
          else return this._projAdd(p);
        };
        Point.prototype.mul = function mul(k) {
          if (this._hasDoubles(k)) return this.curve._fixedNafMul(this, k);
          else return this.curve._wnafMul(this, k);
        };
        Point.prototype.mulAdd = function mulAdd(k1, p, k2) {
          return this.curve._wnafMulAdd(1, [this, p], [k1, k2], 2, false);
        };
        Point.prototype.jmulAdd = function jmulAdd(k1, p, k2) {
          return this.curve._wnafMulAdd(1, [this, p], [k1, k2], 2, true);
        };
        Point.prototype.normalize = function normalize() {
          if (this.zOne) return this;
          var zi = this.z.redInvm();
          this.x = this.x.redMul(zi);
          this.y = this.y.redMul(zi);
          if (this.t) this.t = this.t.redMul(zi);
          this.z = this.curve.one;
          this.zOne = true;
          return this;
        };
        Point.prototype.neg = function neg() {
          return this.curve.point(
            this.x.redNeg(),
            this.y,
            this.z,
            this.t && this.t.redNeg()
          );
        };
        Point.prototype.getX = function getX() {
          this.normalize();
          return this.x.fromRed();
        };
        Point.prototype.getY = function getY() {
          this.normalize();
          return this.y.fromRed();
        };
        Point.prototype.eq = function eq(other) {
          return (
            this === other ||
            (this.getX().cmp(other.getX()) === 0 &&
              this.getY().cmp(other.getY()) === 0)
          );
        };
        Point.prototype.eqXToP = function eqXToP(x) {
          var rx = x.toRed(this.curve.red).redMul(this.z);
          if (this.x.cmp(rx) === 0) return true;
          var xc = x.clone();
          var t = this.curve.redN.redMul(this.z);
          for (;;) {
            xc.iadd(this.curve.n);
            if (xc.cmp(this.curve.p) >= 0) return false;
            rx.redIAdd(t);
            if (this.x.cmp(rx) === 0) return true;
          }
        };
        Point.prototype.toP = Point.prototype.normalize;
        Point.prototype.mixedAdd = Point.prototype.add;
      },
      { "../utils": 42, "./base": 29, "bn.js": 43, inherits: 94 },
    ],
    31: [
      function (require, module, exports) {
        "use strict";
        var curve = exports;
        curve.base = require("./base");
        curve.short = require("./short");
        curve.mont = require("./mont");
        curve.edwards = require("./edwards");
      },
      { "./base": 29, "./edwards": 30, "./mont": 32, "./short": 33 },
    ],
    32: [
      function (require, module, exports) {
        "use strict";
        var BN = require("bn.js");
        var inherits = require("inherits");
        var Base = require("./base");
        var utils = require("../utils");
        function MontCurve(conf) {
          Base.call(this, "mont", conf);
          this.a = new BN(conf.a, 16).toRed(this.red);
          this.b = new BN(conf.b, 16).toRed(this.red);
          this.i4 = new BN(4).toRed(this.red).redInvm();
          this.two = new BN(2).toRed(this.red);
          this.a24 = this.i4.redMul(this.a.redAdd(this.two));
        }
        inherits(MontCurve, Base);
        module.exports = MontCurve;
        MontCurve.prototype.validate = function validate(point) {
          var x = point.normalize().x;
          var x2 = x.redSqr();
          var rhs = x2.redMul(x).redAdd(x2.redMul(this.a)).redAdd(x);
          var y = rhs.redSqrt();
          return y.redSqr().cmp(rhs) === 0;
        };
        function Point(curve, x, z) {
          Base.BasePoint.call(this, curve, "projective");
          if (x === null && z === null) {
            this.x = this.curve.one;
            this.z = this.curve.zero;
          } else {
            this.x = new BN(x, 16);
            this.z = new BN(z, 16);
            if (!this.x.red) this.x = this.x.toRed(this.curve.red);
            if (!this.z.red) this.z = this.z.toRed(this.curve.red);
          }
        }
        inherits(Point, Base.BasePoint);
        MontCurve.prototype.decodePoint = function decodePoint(bytes, enc) {
          return this.point(utils.toArray(bytes, enc), 1);
        };
        MontCurve.prototype.point = function point(x, z) {
          return new Point(this, x, z);
        };
        MontCurve.prototype.pointFromJSON = function pointFromJSON(obj) {
          return Point.fromJSON(this, obj);
        };
        Point.prototype.precompute = function precompute() {};
        Point.prototype._encode = function _encode() {
          return this.getX().toArray("be", this.curve.p.byteLength());
        };
        Point.fromJSON = function fromJSON(curve, obj) {
          return new Point(curve, obj[0], obj[1] || curve.one);
        };
        Point.prototype.inspect = function inspect() {
          if (this.isInfinity()) return "<EC Point Infinity>";
          return (
            "<EC Point x: " +
            this.x.fromRed().toString(16, 2) +
            " z: " +
            this.z.fromRed().toString(16, 2) +
            ">"
          );
        };
        Point.prototype.isInfinity = function isInfinity() {
          return this.z.cmpn(0) === 0;
        };
        Point.prototype.dbl = function dbl() {
          var a = this.x.redAdd(this.z);
          var aa = a.redSqr();
          var b = this.x.redSub(this.z);
          var bb = b.redSqr();
          var c = aa.redSub(bb);
          var nx = aa.redMul(bb);
          var nz = c.redMul(bb.redAdd(this.curve.a24.redMul(c)));
          return this.curve.point(nx, nz);
        };
        Point.prototype.add = function add() {
          throw new Error("Not supported on Montgomery curve");
        };
        Point.prototype.diffAdd = function diffAdd(p, diff) {
          var a = this.x.redAdd(this.z);
          var b = this.x.redSub(this.z);
          var c = p.x.redAdd(p.z);
          var d = p.x.redSub(p.z);
          var da = d.redMul(a);
          var cb = c.redMul(b);
          var nx = diff.z.redMul(da.redAdd(cb).redSqr());
          var nz = diff.x.redMul(da.redISub(cb).redSqr());
          return this.curve.point(nx, nz);
        };
        Point.prototype.mul = function mul(k) {
          var t = k.clone();
          var a = this;
          var b = this.curve.point(null, null);
          var c = this;
          for (var bits = []; t.cmpn(0) !== 0; t.iushrn(1))
            bits.push(t.andln(1));
          for (var i = bits.length - 1; i >= 0; i--) {
            if (bits[i] === 0) {
              a = a.diffAdd(b, c);
              b = b.dbl();
            } else {
              b = a.diffAdd(b, c);
              a = a.dbl();
            }
          }
          return b;
        };
        Point.prototype.mulAdd = function mulAdd() {
          throw new Error("Not supported on Montgomery curve");
        };
        Point.prototype.jumlAdd = function jumlAdd() {
          throw new Error("Not supported on Montgomery curve");
        };
        Point.prototype.eq = function eq(other) {
          return this.getX().cmp(other.getX()) === 0;
        };
        Point.prototype.normalize = function normalize() {
          this.x = this.x.redMul(this.z.redInvm());
          this.z = this.curve.one;
          return this;
        };
        Point.prototype.getX = function getX() {
          this.normalize();
          return this.x.fromRed();
        };
      },
      { "../utils": 42, "./base": 29, "bn.js": 43, inherits: 94 },
    ],
    33: [
      function (require, module, exports) {
        "use strict";
        var utils = require("../utils");
        var BN = require("bn.js");
        var inherits = require("inherits");
        var Base = require("./base");
        var assert = utils.assert;
        function ShortCurve(conf) {
          Base.call(this, "short", conf);
          this.a = new BN(conf.a, 16).toRed(this.red);
          this.b = new BN(conf.b, 16).toRed(this.red);
          this.tinv = this.two.redInvm();
          this.zeroA = this.a.fromRed().cmpn(0) === 0;
          this.threeA = this.a.fromRed().sub(this.p).cmpn(-3) === 0;
          this.endo = this._getEndomorphism(conf);
          this._endoWnafT1 = new Array(4);
          this._endoWnafT2 = new Array(4);
        }
        inherits(ShortCurve, Base);
        module.exports = ShortCurve;
        ShortCurve.prototype._getEndomorphism = function _getEndomorphism(
          conf
        ) {
          if (!this.zeroA || !this.g || !this.n || this.p.modn(3) !== 1) return;
          var beta;
          var lambda;
          if (conf.beta) {
            beta = new BN(conf.beta, 16).toRed(this.red);
          } else {
            var betas = this._getEndoRoots(this.p);
            beta = betas[0].cmp(betas[1]) < 0 ? betas[0] : betas[1];
            beta = beta.toRed(this.red);
          }
          if (conf.lambda) {
            lambda = new BN(conf.lambda, 16);
          } else {
            var lambdas = this._getEndoRoots(this.n);
            if (this.g.mul(lambdas[0]).x.cmp(this.g.x.redMul(beta)) === 0) {
              lambda = lambdas[0];
            } else {
              lambda = lambdas[1];
              assert(this.g.mul(lambda).x.cmp(this.g.x.redMul(beta)) === 0);
            }
          }
          var basis;
          if (conf.basis) {
            basis = conf.basis.map(function (vec) {
              return { a: new BN(vec.a, 16), b: new BN(vec.b, 16) };
            });
          } else {
            basis = this._getEndoBasis(lambda);
          }
          return { beta: beta, lambda: lambda, basis: basis };
        };
        ShortCurve.prototype._getEndoRoots = function _getEndoRoots(num) {
          var red = num === this.p ? this.red : BN.mont(num);
          var tinv = new BN(2).toRed(red).redInvm();
          var ntinv = tinv.redNeg();
          var s = new BN(3).toRed(red).redNeg().redSqrt().redMul(tinv);
          var l1 = ntinv.redAdd(s).fromRed();
          var l2 = ntinv.redSub(s).fromRed();
          return [l1, l2];
        };
        ShortCurve.prototype._getEndoBasis = function _getEndoBasis(lambda) {
          var aprxSqrt = this.n.ushrn(Math.floor(this.n.bitLength() / 2));
          var u = lambda;
          var v = this.n.clone();
          var x1 = new BN(1);
          var y1 = new BN(0);
          var x2 = new BN(0);
          var y2 = new BN(1);
          var a0;
          var b0;
          var a1;
          var b1;
          var a2;
          var b2;
          var prevR;
          var i = 0;
          var r;
          var x;
          while (u.cmpn(0) !== 0) {
            var q = v.div(u);
            r = v.sub(q.mul(u));
            x = x2.sub(q.mul(x1));
            var y = y2.sub(q.mul(y1));
            if (!a1 && r.cmp(aprxSqrt) < 0) {
              a0 = prevR.neg();
              b0 = x1;
              a1 = r.neg();
              b1 = x;
            } else if (a1 && ++i === 2) {
              break;
            }
            prevR = r;
            v = u;
            u = r;
            x2 = x1;
            x1 = x;
            y2 = y1;
            y1 = y;
          }
          a2 = r.neg();
          b2 = x;
          var len1 = a1.sqr().add(b1.sqr());
          var len2 = a2.sqr().add(b2.sqr());
          if (len2.cmp(len1) >= 0) {
            a2 = a0;
            b2 = b0;
          }
          if (a1.negative) {
            a1 = a1.neg();
            b1 = b1.neg();
          }
          if (a2.negative) {
            a2 = a2.neg();
            b2 = b2.neg();
          }
          return [
            { a: a1, b: b1 },
            { a: a2, b: b2 },
          ];
        };
        ShortCurve.prototype._endoSplit = function _endoSplit(k) {
          var basis = this.endo.basis;
          var v1 = basis[0];
          var v2 = basis[1];
          var c1 = v2.b.mul(k).divRound(this.n);
          var c2 = v1.b.neg().mul(k).divRound(this.n);
          var p1 = c1.mul(v1.a);
          var p2 = c2.mul(v2.a);
          var q1 = c1.mul(v1.b);
          var q2 = c2.mul(v2.b);
          var k1 = k.sub(p1).sub(p2);
          var k2 = q1.add(q2).neg();
          return { k1: k1, k2: k2 };
        };
        ShortCurve.prototype.pointFromX = function pointFromX(x, odd) {
          x = new BN(x, 16);
          if (!x.red) x = x.toRed(this.red);
          var y2 = x
            .redSqr()
            .redMul(x)
            .redIAdd(x.redMul(this.a))
            .redIAdd(this.b);
          var y = y2.redSqrt();
          if (y.redSqr().redSub(y2).cmp(this.zero) !== 0)
            throw new Error("invalid point");
          var isOdd = y.fromRed().isOdd();
          if ((odd && !isOdd) || (!odd && isOdd)) y = y.redNeg();
          return this.point(x, y);
        };
        ShortCurve.prototype.validate = function validate(point) {
          if (point.inf) return true;
          var x = point.x;
          var y = point.y;
          var ax = this.a.redMul(x);
          var rhs = x.redSqr().redMul(x).redIAdd(ax).redIAdd(this.b);
          return y.redSqr().redISub(rhs).cmpn(0) === 0;
        };
        ShortCurve.prototype._endoWnafMulAdd = function _endoWnafMulAdd(
          points,
          coeffs,
          jacobianResult
        ) {
          var npoints = this._endoWnafT1;
          var ncoeffs = this._endoWnafT2;
          for (var i = 0; i < points.length; i++) {
            var split = this._endoSplit(coeffs[i]);
            var p = points[i];
            var beta = p._getBeta();
            if (split.k1.negative) {
              split.k1.ineg();
              p = p.neg(true);
            }
            if (split.k2.negative) {
              split.k2.ineg();
              beta = beta.neg(true);
            }
            npoints[i * 2] = p;
            npoints[i * 2 + 1] = beta;
            ncoeffs[i * 2] = split.k1;
            ncoeffs[i * 2 + 1] = split.k2;
          }
          var res = this._wnafMulAdd(
            1,
            npoints,
            ncoeffs,
            i * 2,
            jacobianResult
          );
          for (var j = 0; j < i * 2; j++) {
            npoints[j] = null;
            ncoeffs[j] = null;
          }
          return res;
        };
        function Point(curve, x, y, isRed) {
          Base.BasePoint.call(this, curve, "affine");
          if (x === null && y === null) {
            this.x = null;
            this.y = null;
            this.inf = true;
          } else {
            this.x = new BN(x, 16);
            this.y = new BN(y, 16);
            if (isRed) {
              this.x.forceRed(this.curve.red);
              this.y.forceRed(this.curve.red);
            }
            if (!this.x.red) this.x = this.x.toRed(this.curve.red);
            if (!this.y.red) this.y = this.y.toRed(this.curve.red);
            this.inf = false;
          }
        }
        inherits(Point, Base.BasePoint);
        ShortCurve.prototype.point = function point(x, y, isRed) {
          return new Point(this, x, y, isRed);
        };
        ShortCurve.prototype.pointFromJSON = function pointFromJSON(obj, red) {
          return Point.fromJSON(this, obj, red);
        };
        Point.prototype._getBeta = function _getBeta() {
          if (!this.curve.endo) return;
          var pre = this.precomputed;
          if (pre && pre.beta) return pre.beta;
          var beta = this.curve.point(
            this.x.redMul(this.curve.endo.beta),
            this.y
          );
          if (pre) {
            var curve = this.curve;
            var endoMul = function (p) {
              return curve.point(p.x.redMul(curve.endo.beta), p.y);
            };
            pre.beta = beta;
            beta.precomputed = {
              beta: null,
              naf: pre.naf && {
                wnd: pre.naf.wnd,
                points: pre.naf.points.map(endoMul),
              },
              doubles: pre.doubles && {
                step: pre.doubles.step,
                points: pre.doubles.points.map(endoMul),
              },
            };
          }
          return beta;
        };
        Point.prototype.toJSON = function toJSON() {
          if (!this.precomputed) return [this.x, this.y];
          return [
            this.x,
            this.y,
            this.precomputed && {
              doubles: this.precomputed.doubles && {
                step: this.precomputed.doubles.step,
                points: this.precomputed.doubles.points.slice(1),
              },
              naf: this.precomputed.naf && {
                wnd: this.precomputed.naf.wnd,
                points: this.precomputed.naf.points.slice(1),
              },
            },
          ];
        };
        Point.fromJSON = function fromJSON(curve, obj, red) {
          if (typeof obj === "string") obj = JSON.parse(obj);
          var res = curve.point(obj[0], obj[1], red);
          if (!obj[2]) return res;
          function obj2point(obj) {
            return curve.point(obj[0], obj[1], red);
          }
          var pre = obj[2];
          res.precomputed = {
            beta: null,
            doubles: pre.doubles && {
              step: pre.doubles.step,
              points: [res].concat(pre.doubles.points.map(obj2point)),
            },
            naf: pre.naf && {
              wnd: pre.naf.wnd,
              points: [res].concat(pre.naf.points.map(obj2point)),
            },
          };
          return res;
        };
        Point.prototype.inspect = function inspect() {
          if (this.isInfinity()) return "<EC Point Infinity>";
          return (
            "<EC Point x: " +
            this.x.fromRed().toString(16, 2) +
            " y: " +
            this.y.fromRed().toString(16, 2) +
            ">"
          );
        };
        Point.prototype.isInfinity = function isInfinity() {
          return this.inf;
        };
        Point.prototype.add = function add(p) {
          if (this.inf) return p;
          if (p.inf) return this;
          if (this.eq(p)) return this.dbl();
          if (this.neg().eq(p)) return this.curve.point(null, null);
          if (this.x.cmp(p.x) === 0) return this.curve.point(null, null);
          var c = this.y.redSub(p.y);
          if (c.cmpn(0) !== 0) c = c.redMul(this.x.redSub(p.x).redInvm());
          var nx = c.redSqr().redISub(this.x).redISub(p.x);
          var ny = c.redMul(this.x.redSub(nx)).redISub(this.y);
          return this.curve.point(nx, ny);
        };
        Point.prototype.dbl = function dbl() {
          if (this.inf) return this;
          var ys1 = this.y.redAdd(this.y);
          if (ys1.cmpn(0) === 0) return this.curve.point(null, null);
          var a = this.curve.a;
          var x2 = this.x.redSqr();
          var dyinv = ys1.redInvm();
          var c = x2.redAdd(x2).redIAdd(x2).redIAdd(a).redMul(dyinv);
          var nx = c.redSqr().redISub(this.x.redAdd(this.x));
          var ny = c.redMul(this.x.redSub(nx)).redISub(this.y);
          return this.curve.point(nx, ny);
        };
        Point.prototype.getX = function getX() {
          return this.x.fromRed();
        };
        Point.prototype.getY = function getY() {
          return this.y.fromRed();
        };
        Point.prototype.mul = function mul(k) {
          k = new BN(k, 16);
          if (this.isInfinity()) return this;
          else if (this._hasDoubles(k)) return this.curve._fixedNafMul(this, k);
          else if (this.curve.endo)
            return this.curve._endoWnafMulAdd([this], [k]);
          else return this.curve._wnafMul(this, k);
        };
        Point.prototype.mulAdd = function mulAdd(k1, p2, k2) {
          var points = [this, p2];
          var coeffs = [k1, k2];
          if (this.curve.endo)
            return this.curve._endoWnafMulAdd(points, coeffs);
          else return this.curve._wnafMulAdd(1, points, coeffs, 2);
        };
        Point.prototype.jmulAdd = function jmulAdd(k1, p2, k2) {
          var points = [this, p2];
          var coeffs = [k1, k2];
          if (this.curve.endo)
            return this.curve._endoWnafMulAdd(points, coeffs, true);
          else return this.curve._wnafMulAdd(1, points, coeffs, 2, true);
        };
        Point.prototype.eq = function eq(p) {
          return (
            this === p ||
            (this.inf === p.inf &&
              (this.inf || (this.x.cmp(p.x) === 0 && this.y.cmp(p.y) === 0)))
          );
        };
        Point.prototype.neg = function neg(_precompute) {
          if (this.inf) return this;
          var res = this.curve.point(this.x, this.y.redNeg());
          if (_precompute && this.precomputed) {
            var pre = this.precomputed;
            var negate = function (p) {
              return p.neg();
            };
            res.precomputed = {
              naf: pre.naf && {
                wnd: pre.naf.wnd,
                points: pre.naf.points.map(negate),
              },
              doubles: pre.doubles && {
                step: pre.doubles.step,
                points: pre.doubles.points.map(negate),
              },
            };
          }
          return res;
        };
        Point.prototype.toJ = function toJ() {
          if (this.inf) return this.curve.jpoint(null, null, null);
          var res = this.curve.jpoint(this.x, this.y, this.curve.one);
          return res;
        };
        function JPoint(curve, x, y, z) {
          Base.BasePoint.call(this, curve, "jacobian");
          if (x === null && y === null && z === null) {
            this.x = this.curve.one;
            this.y = this.curve.one;
            this.z = new BN(0);
          } else {
            this.x = new BN(x, 16);
            this.y = new BN(y, 16);
            this.z = new BN(z, 16);
          }
          if (!this.x.red) this.x = this.x.toRed(this.curve.red);
          if (!this.y.red) this.y = this.y.toRed(this.curve.red);
          if (!this.z.red) this.z = this.z.toRed(this.curve.red);
          this.zOne = this.z === this.curve.one;
        }
        inherits(JPoint, Base.BasePoint);
        ShortCurve.prototype.jpoint = function jpoint(x, y, z) {
          return new JPoint(this, x, y, z);
        };
        JPoint.prototype.toP = function toP() {
          if (this.isInfinity()) return this.curve.point(null, null);
          var zinv = this.z.redInvm();
          var zinv2 = zinv.redSqr();
          var ax = this.x.redMul(zinv2);
          var ay = this.y.redMul(zinv2).redMul(zinv);
          return this.curve.point(ax, ay);
        };
        JPoint.prototype.neg = function neg() {
          return this.curve.jpoint(this.x, this.y.redNeg(), this.z);
        };
        JPoint.prototype.add = function add(p) {
          if (this.isInfinity()) return p;
          if (p.isInfinity()) return this;
          var pz2 = p.z.redSqr();
          var z2 = this.z.redSqr();
          var u1 = this.x.redMul(pz2);
          var u2 = p.x.redMul(z2);
          var s1 = this.y.redMul(pz2.redMul(p.z));
          var s2 = p.y.redMul(z2.redMul(this.z));
          var h = u1.redSub(u2);
          var r = s1.redSub(s2);
          if (h.cmpn(0) === 0) {
            if (r.cmpn(0) !== 0) return this.curve.jpoint(null, null, null);
            else return this.dbl();
          }
          var h2 = h.redSqr();
          var h3 = h2.redMul(h);
          var v = u1.redMul(h2);
          var nx = r.redSqr().redIAdd(h3).redISub(v).redISub(v);
          var ny = r.redMul(v.redISub(nx)).redISub(s1.redMul(h3));
          var nz = this.z.redMul(p.z).redMul(h);
          return this.curve.jpoint(nx, ny, nz);
        };
        JPoint.prototype.mixedAdd = function mixedAdd(p) {
          if (this.isInfinity()) return p.toJ();
          if (p.isInfinity()) return this;
          var z2 = this.z.redSqr();
          var u1 = this.x;
          var u2 = p.x.redMul(z2);
          var s1 = this.y;
          var s2 = p.y.redMul(z2).redMul(this.z);
          var h = u1.redSub(u2);
          var r = s1.redSub(s2);
          if (h.cmpn(0) === 0) {
            if (r.cmpn(0) !== 0) return this.curve.jpoint(null, null, null);
            else return this.dbl();
          }
          var h2 = h.redSqr();
          var h3 = h2.redMul(h);
          var v = u1.redMul(h2);
          var nx = r.redSqr().redIAdd(h3).redISub(v).redISub(v);
          var ny = r.redMul(v.redISub(nx)).redISub(s1.redMul(h3));
          var nz = this.z.redMul(h);
          return this.curve.jpoint(nx, ny, nz);
        };
        JPoint.prototype.dblp = function dblp(pow) {
          if (pow === 0) return this;
          if (this.isInfinity()) return this;
          if (!pow) return this.dbl();
          var i;
          if (this.curve.zeroA || this.curve.threeA) {
            var r = this;
            for (i = 0; i < pow; i++) r = r.dbl();
            return r;
          }
          var a = this.curve.a;
          var tinv = this.curve.tinv;
          var jx = this.x;
          var jy = this.y;
          var jz = this.z;
          var jz4 = jz.redSqr().redSqr();
          var jyd = jy.redAdd(jy);
          for (i = 0; i < pow; i++) {
            var jx2 = jx.redSqr();
            var jyd2 = jyd.redSqr();
            var jyd4 = jyd2.redSqr();
            var c = jx2.redAdd(jx2).redIAdd(jx2).redIAdd(a.redMul(jz4));
            var t1 = jx.redMul(jyd2);
            var nx = c.redSqr().redISub(t1.redAdd(t1));
            var t2 = t1.redISub(nx);
            var dny = c.redMul(t2);
            dny = dny.redIAdd(dny).redISub(jyd4);
            var nz = jyd.redMul(jz);
            if (i + 1 < pow) jz4 = jz4.redMul(jyd4);
            jx = nx;
            jz = nz;
            jyd = dny;
          }
          return this.curve.jpoint(jx, jyd.redMul(tinv), jz);
        };
        JPoint.prototype.dbl = function dbl() {
          if (this.isInfinity()) return this;
          if (this.curve.zeroA) return this._zeroDbl();
          else if (this.curve.threeA) return this._threeDbl();
          else return this._dbl();
        };
        JPoint.prototype._zeroDbl = function _zeroDbl() {
          var nx;
          var ny;
          var nz;
          if (this.zOne) {
            var xx = this.x.redSqr();
            var yy = this.y.redSqr();
            var yyyy = yy.redSqr();
            var s = this.x.redAdd(yy).redSqr().redISub(xx).redISub(yyyy);
            s = s.redIAdd(s);
            var m = xx.redAdd(xx).redIAdd(xx);
            var t = m.redSqr().redISub(s).redISub(s);
            var yyyy8 = yyyy.redIAdd(yyyy);
            yyyy8 = yyyy8.redIAdd(yyyy8);
            yyyy8 = yyyy8.redIAdd(yyyy8);
            nx = t;
            ny = m.redMul(s.redISub(t)).redISub(yyyy8);
            nz = this.y.redAdd(this.y);
          } else {
            var a = this.x.redSqr();
            var b = this.y.redSqr();
            var c = b.redSqr();
            var d = this.x.redAdd(b).redSqr().redISub(a).redISub(c);
            d = d.redIAdd(d);
            var e = a.redAdd(a).redIAdd(a);
            var f = e.redSqr();
            var c8 = c.redIAdd(c);
            c8 = c8.redIAdd(c8);
            c8 = c8.redIAdd(c8);
            nx = f.redISub(d).redISub(d);
            ny = e.redMul(d.redISub(nx)).redISub(c8);
            nz = this.y.redMul(this.z);
            nz = nz.redIAdd(nz);
          }
          return this.curve.jpoint(nx, ny, nz);
        };
        JPoint.prototype._threeDbl = function _threeDbl() {
          var nx;
          var ny;
          var nz;
          if (this.zOne) {
            var xx = this.x.redSqr();
            var yy = this.y.redSqr();
            var yyyy = yy.redSqr();
            var s = this.x.redAdd(yy).redSqr().redISub(xx).redISub(yyyy);
            s = s.redIAdd(s);
            var m = xx.redAdd(xx).redIAdd(xx).redIAdd(this.curve.a);
            var t = m.redSqr().redISub(s).redISub(s);
            nx = t;
            var yyyy8 = yyyy.redIAdd(yyyy);
            yyyy8 = yyyy8.redIAdd(yyyy8);
            yyyy8 = yyyy8.redIAdd(yyyy8);
            ny = m.redMul(s.redISub(t)).redISub(yyyy8);
            nz = this.y.redAdd(this.y);
          } else {
            var delta = this.z.redSqr();
            var gamma = this.y.redSqr();
            var beta = this.x.redMul(gamma);
            var alpha = this.x.redSub(delta).redMul(this.x.redAdd(delta));
            alpha = alpha.redAdd(alpha).redIAdd(alpha);
            var beta4 = beta.redIAdd(beta);
            beta4 = beta4.redIAdd(beta4);
            var beta8 = beta4.redAdd(beta4);
            nx = alpha.redSqr().redISub(beta8);
            nz = this.y.redAdd(this.z).redSqr().redISub(gamma).redISub(delta);
            var ggamma8 = gamma.redSqr();
            ggamma8 = ggamma8.redIAdd(ggamma8);
            ggamma8 = ggamma8.redIAdd(ggamma8);
            ggamma8 = ggamma8.redIAdd(ggamma8);
            ny = alpha.redMul(beta4.redISub(nx)).redISub(ggamma8);
          }
          return this.curve.jpoint(nx, ny, nz);
        };
        JPoint.prototype._dbl = function _dbl() {
          var a = this.curve.a;
          var jx = this.x;
          var jy = this.y;
          var jz = this.z;
          var jz4 = jz.redSqr().redSqr();
          var jx2 = jx.redSqr();
          var jy2 = jy.redSqr();
          var c = jx2.redAdd(jx2).redIAdd(jx2).redIAdd(a.redMul(jz4));
          var jxd4 = jx.redAdd(jx);
          jxd4 = jxd4.redIAdd(jxd4);
          var t1 = jxd4.redMul(jy2);
          var nx = c.redSqr().redISub(t1.redAdd(t1));
          var t2 = t1.redISub(nx);
          var jyd8 = jy2.redSqr();
          jyd8 = jyd8.redIAdd(jyd8);
          jyd8 = jyd8.redIAdd(jyd8);
          jyd8 = jyd8.redIAdd(jyd8);
          var ny = c.redMul(t2).redISub(jyd8);
          var nz = jy.redAdd(jy).redMul(jz);
          return this.curve.jpoint(nx, ny, nz);
        };
        JPoint.prototype.trpl = function trpl() {
          if (!this.curve.zeroA) return this.dbl().add(this);
          var xx = this.x.redSqr();
          var yy = this.y.redSqr();
          var zz = this.z.redSqr();
          var yyyy = yy.redSqr();
          var m = xx.redAdd(xx).redIAdd(xx);
          var mm = m.redSqr();
          var e = this.x.redAdd(yy).redSqr().redISub(xx).redISub(yyyy);
          e = e.redIAdd(e);
          e = e.redAdd(e).redIAdd(e);
          e = e.redISub(mm);
          var ee = e.redSqr();
          var t = yyyy.redIAdd(yyyy);
          t = t.redIAdd(t);
          t = t.redIAdd(t);
          t = t.redIAdd(t);
          var u = m.redIAdd(e).redSqr().redISub(mm).redISub(ee).redISub(t);
          var yyu4 = yy.redMul(u);
          yyu4 = yyu4.redIAdd(yyu4);
          yyu4 = yyu4.redIAdd(yyu4);
          var nx = this.x.redMul(ee).redISub(yyu4);
          nx = nx.redIAdd(nx);
          nx = nx.redIAdd(nx);
          var ny = this.y.redMul(u.redMul(t.redISub(u)).redISub(e.redMul(ee)));
          ny = ny.redIAdd(ny);
          ny = ny.redIAdd(ny);
          ny = ny.redIAdd(ny);
          var nz = this.z.redAdd(e).redSqr().redISub(zz).redISub(ee);
          return this.curve.jpoint(nx, ny, nz);
        };
        JPoint.prototype.mul = function mul(k, kbase) {
          k = new BN(k, kbase);
          return this.curve._wnafMul(this, k);
        };
        JPoint.prototype.eq = function eq(p) {
          if (p.type === "affine") return this.eq(p.toJ());
          if (this === p) return true;
          var z2 = this.z.redSqr();
          var pz2 = p.z.redSqr();
          if (this.x.redMul(pz2).redISub(p.x.redMul(z2)).cmpn(0) !== 0)
            return false;
          var z3 = z2.redMul(this.z);
          var pz3 = pz2.redMul(p.z);
          return this.y.redMul(pz3).redISub(p.y.redMul(z3)).cmpn(0) === 0;
        };
        JPoint.prototype.eqXToP = function eqXToP(x) {
          var zs = this.z.redSqr();
          var rx = x.toRed(this.curve.red).redMul(zs);
          if (this.x.cmp(rx) === 0) return true;
          var xc = x.clone();
          var t = this.curve.redN.redMul(zs);
          for (;;) {
            xc.iadd(this.curve.n);
            if (xc.cmp(this.curve.p) >= 0) return false;
            rx.redIAdd(t);
            if (this.x.cmp(rx) === 0) return true;
          }
        };
        JPoint.prototype.inspect = function inspect() {
          if (this.isInfinity()) return "<EC JPoint Infinity>";
          return (
            "<EC JPoint x: " +
            this.x.toString(16, 2) +
            " y: " +
            this.y.toString(16, 2) +
            " z: " +
            this.z.toString(16, 2) +
            ">"
          );
        };
        JPoint.prototype.isInfinity = function isInfinity() {
          return this.z.cmpn(0) === 0;
        };
      },
      { "../utils": 42, "./base": 29, "bn.js": 43, inherits: 94 },
    ],
    34: [
      function (require, module, exports) {
        "use strict";
        var curves = exports;
        var hash = require("hash.js");
        var curve = require("./curve");
        var utils = require("./utils");
        var assert = utils.assert;
        function PresetCurve(options) {
          if (options.type === "short") this.curve = new curve.short(options);
          else if (options.type === "edwards")
            this.curve = new curve.edwards(options);
          else this.curve = new curve.mont(options);
          this.g = this.curve.g;
          this.n = this.curve.n;
          this.hash = options.hash;
          assert(this.g.validate(), "Invalid curve");
          assert(this.g.mul(this.n).isInfinity(), "Invalid curve, G*N != O");
        }
        curves.PresetCurve = PresetCurve;
        function defineCurve(name, options) {
          Object.defineProperty(curves, name, {
            configurable: true,
            enumerable: true,
            get: function () {
              var curve = new PresetCurve(options);
              Object.defineProperty(curves, name, {
                configurable: true,
                enumerable: true,
                value: curve,
              });
              return curve;
            },
          });
        }
        defineCurve("p192", {
          type: "short",
          prime: "p192",
          p: "ffffffff ffffffff ffffffff fffffffe ffffffff ffffffff",
          a: "ffffffff ffffffff ffffffff fffffffe ffffffff fffffffc",
          b: "64210519 e59c80e7 0fa7e9ab 72243049 feb8deec c146b9b1",
          n: "ffffffff ffffffff ffffffff 99def836 146bc9b1 b4d22831",
          hash: hash.sha256,
          gRed: false,
          g: [
            "188da80e b03090f6 7cbf20eb 43a18800 f4ff0afd 82ff1012",
            "07192b95 ffc8da78 631011ed 6b24cdd5 73f977a1 1e794811",
          ],
        });
        defineCurve("p224", {
          type: "short",
          prime: "p224",
          p: "ffffffff ffffffff ffffffff ffffffff 00000000 00000000 00000001",
          a: "ffffffff ffffffff ffffffff fffffffe ffffffff ffffffff fffffffe",
          b: "b4050a85 0c04b3ab f5413256 5044b0b7 d7bfd8ba 270b3943 2355ffb4",
          n: "ffffffff ffffffff ffffffff ffff16a2 e0b8f03e 13dd2945 5c5c2a3d",
          hash: hash.sha256,
          gRed: false,
          g: [
            "b70e0cbd 6bb4bf7f 321390b9 4a03c1d3 56c21122 343280d6 115c1d21",
            "bd376388 b5f723fb 4c22dfe6 cd4375a0 5a074764 44d58199 85007e34",
          ],
        });
        defineCurve("p256", {
          type: "short",
          prime: null,
          p: "ffffffff 00000001 00000000 00000000 00000000 ffffffff ffffffff ffffffff",
          a: "ffffffff 00000001 00000000 00000000 00000000 ffffffff ffffffff fffffffc",
          b: "5ac635d8 aa3a93e7 b3ebbd55 769886bc 651d06b0 cc53b0f6 3bce3c3e 27d2604b",
          n: "ffffffff 00000000 ffffffff ffffffff bce6faad a7179e84 f3b9cac2 fc632551",
          hash: hash.sha256,
          gRed: false,
          g: [
            "6b17d1f2 e12c4247 f8bce6e5 63a440f2 77037d81 2deb33a0 f4a13945 d898c296",
            "4fe342e2 fe1a7f9b 8ee7eb4a 7c0f9e16 2bce3357 6b315ece cbb64068 37bf51f5",
          ],
        });
        defineCurve("p384", {
          type: "short",
          prime: null,
          p:
            "ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff " +
            "fffffffe ffffffff 00000000 00000000 ffffffff",
          a:
            "ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff " +
            "fffffffe ffffffff 00000000 00000000 fffffffc",
          b:
            "b3312fa7 e23ee7e4 988e056b e3f82d19 181d9c6e fe814112 0314088f " +
            "5013875a c656398d 8a2ed19d 2a85c8ed d3ec2aef",
          n:
            "ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff c7634d81 " +
            "f4372ddf 581a0db2 48b0a77a ecec196a ccc52973",
          hash: hash.sha384,
          gRed: false,
          g: [
            "aa87ca22 be8b0537 8eb1c71e f320ad74 6e1d3b62 8ba79b98 59f741e0 82542a38 " +
              "5502f25d bf55296c 3a545e38 72760ab7",
            "3617de4a 96262c6f 5d9e98bf 9292dc29 f8f41dbd 289a147c e9da3113 b5f0b8c0 " +
              "0a60b1ce 1d7e819d 7a431d7c 90ea0e5f",
          ],
        });
        defineCurve("p521", {
          type: "short",
          prime: null,
          p:
            "000001ff ffffffff ffffffff ffffffff ffffffff ffffffff " +
            "ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff " +
            "ffffffff ffffffff ffffffff ffffffff ffffffff",
          a:
            "000001ff ffffffff ffffffff ffffffff ffffffff ffffffff " +
            "ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff " +
            "ffffffff ffffffff ffffffff ffffffff fffffffc",
          b:
            "00000051 953eb961 8e1c9a1f 929a21a0 b68540ee a2da725b " +
            "99b315f3 b8b48991 8ef109e1 56193951 ec7e937b 1652c0bd " +
            "3bb1bf07 3573df88 3d2c34f1 ef451fd4 6b503f00",
          n:
            "000001ff ffffffff ffffffff ffffffff ffffffff ffffffff " +
            "ffffffff ffffffff fffffffa 51868783 bf2f966b 7fcc0148 " +
            "f709a5d0 3bb5c9b8 899c47ae bb6fb71e 91386409",
          hash: hash.sha512,
          gRed: false,
          g: [
            "000000c6 858e06b7 0404e9cd 9e3ecb66 2395b442 9c648139 " +
              "053fb521 f828af60 6b4d3dba a14b5e77 efe75928 fe1dc127 " +
              "a2ffa8de 3348b3c1 856a429b f97e7e31 c2e5bd66",
            "00000118 39296a78 9a3bc004 5c8a5fb4 2c7d1bd9 98f54449 " +
              "579b4468 17afbd17 273e662c 97ee7299 5ef42640 c550b901 " +
              "3fad0761 353c7086 a272c240 88be9476 9fd16650",
          ],
        });
        defineCurve("curve25519", {
          type: "mont",
          prime: "p25519",
          p: "7fffffffffffffff ffffffffffffffff ffffffffffffffff ffffffffffffffed",
          a: "76d06",
          b: "1",
          n: "1000000000000000 0000000000000000 14def9dea2f79cd6 5812631a5cf5d3ed",
          hash: hash.sha256,
          gRed: false,
          g: ["9"],
        });
        defineCurve("ed25519", {
          type: "edwards",
          prime: "p25519",
          p: "7fffffffffffffff ffffffffffffffff ffffffffffffffff ffffffffffffffed",
          a: "-1",
          c: "1",
          d: "52036cee2b6ffe73 8cc740797779e898 00700a4d4141d8ab 75eb4dca135978a3",
          n: "1000000000000000 0000000000000000 14def9dea2f79cd6 5812631a5cf5d3ed",
          hash: hash.sha256,
          gRed: false,
          g: [
            "216936d3cd6e53fec0a4e231fdd6dc5c692cc7609525a7b2c9562d608f25d51a",
            "6666666666666666666666666666666666666666666666666666666666666658",
          ],
        });
        var pre;
        try {
          pre = require("./precomputed/secp256k1");
        } catch (e) {
          pre = undefined;
        }
        defineCurve("secp256k1", {
          type: "short",
          prime: "k256",
          p: "ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff fffffffe fffffc2f",
          a: "0",
          b: "7",
          n: "ffffffff ffffffff ffffffff fffffffe baaedce6 af48a03b bfd25e8c d0364141",
          h: "1",
          hash: hash.sha256,
          beta: "7ae96a2b657c07106e64479eac3434e99cf0497512f58995c1396c28719501ee",
          lambda:
            "5363ad4cc05c30e0a5261c028812645a122e22ea20816678df02967c1b23bd72",
          basis: [
            {
              a: "3086d221a7d46bcde86c90e49284eb15",
              b: "-e4437ed6010e88286f547fa90abfe4c3",
            },
            {
              a: "114ca50f7a8e2f3f657c1108d9d44cfd8",
              b: "3086d221a7d46bcde86c90e49284eb15",
            },
          ],
          gRed: false,
          g: [
            "79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798",
            "483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8",
            pre,
          ],
        });
      },
      {
        "./curve": 31,
        "./precomputed/secp256k1": 41,
        "./utils": 42,
        "hash.js": 80,
      },
    ],
    35: [
      function (require, module, exports) {
        "use strict";
        var BN = require("bn.js");
        var HmacDRBG = require("hmac-drbg");
        var utils = require("../utils");
        var curves = require("../curves");
        var rand = require("brorand");
        var assert = utils.assert;
        var KeyPair = require("./key");
        var Signature = require("./signature");
        function EC(options) {
          if (!(this instanceof EC)) return new EC(options);
          if (typeof options === "string") {
            assert(
              Object.prototype.hasOwnProperty.call(curves, options),
              "Unknown curve " + options
            );
            options = curves[options];
          }
          if (options instanceof curves.PresetCurve)
            options = { curve: options };
          this.curve = options.curve.curve;
          this.n = this.curve.n;
          this.nh = this.n.ushrn(1);
          this.g = this.curve.g;
          this.g = options.curve.g;
          this.g.precompute(options.curve.n.bitLength() + 1);
          this.hash = options.hash || options.curve.hash;
        }
        module.exports = EC;
        EC.prototype.keyPair = function keyPair(options) {
          return new KeyPair(this, options);
        };
        EC.prototype.keyFromPrivate = function keyFromPrivate(priv, enc) {
          return KeyPair.fromPrivate(this, priv, enc);
        };
        EC.prototype.keyFromPublic = function keyFromPublic(pub, enc) {
          return KeyPair.fromPublic(this, pub, enc);
        };
        EC.prototype.genKeyPair = function genKeyPair(options) {
          if (!options) options = {};
          var drbg = new HmacDRBG({
            hash: this.hash,
            pers: options.pers,
            persEnc: options.persEnc || "utf8",
            entropy: options.entropy || rand(this.hash.hmacStrength),
            entropyEnc: (options.entropy && options.entropyEnc) || "utf8",
            nonce: this.n.toArray(),
          });
          var bytes = this.n.byteLength();
          var ns2 = this.n.sub(new BN(2));
          for (;;) {
            var priv = new BN(drbg.generate(bytes));
            if (priv.cmp(ns2) > 0) continue;
            priv.iaddn(1);
            return this.keyFromPrivate(priv);
          }
        };
        EC.prototype._truncateToN = function _truncateToN(msg, truncOnly) {
          var delta = msg.byteLength() * 8 - this.n.bitLength();
          if (delta > 0) msg = msg.ushrn(delta);
          if (!truncOnly && msg.cmp(this.n) >= 0) return msg.sub(this.n);
          else return msg;
        };
        EC.prototype.sign = function sign(msg, key, enc, options) {
          if (typeof enc === "object") {
            options = enc;
            enc = null;
          }
          if (!options) options = {};
          key = this.keyFromPrivate(key, enc);
          msg = this._truncateToN(new BN(msg, 16));
          var bytes = this.n.byteLength();
          var bkey = key.getPrivate().toArray("be", bytes);
          var nonce = msg.toArray("be", bytes);
          var drbg = new HmacDRBG({
            hash: this.hash,
            entropy: bkey,
            nonce: nonce,
            pers: options.pers,
            persEnc: options.persEnc || "utf8",
          });
          var ns1 = this.n.sub(new BN(1));
          for (var iter = 0; ; iter++) {
            var k = options.k
              ? options.k(iter)
              : new BN(drbg.generate(this.n.byteLength()));
            k = this._truncateToN(k, true);
            if (k.cmpn(1) <= 0 || k.cmp(ns1) >= 0) continue;
            var kp = this.g.mul(k);
            if (kp.isInfinity()) continue;
            var kpX = kp.getX();
            var r = kpX.umod(this.n);
            if (r.cmpn(0) === 0) continue;
            var s = k.invm(this.n).mul(r.mul(key.getPrivate()).iadd(msg));
            s = s.umod(this.n);
            if (s.cmpn(0) === 0) continue;
            var recoveryParam =
              (kp.getY().isOdd() ? 1 : 0) | (kpX.cmp(r) !== 0 ? 2 : 0);
            if (options.canonical && s.cmp(this.nh) > 0) {
              s = this.n.sub(s);
              recoveryParam ^= 1;
            }
            return new Signature({ r: r, s: s, recoveryParam: recoveryParam });
          }
        };
        EC.prototype.verify = function verify(msg, signature, key, enc) {
          msg = this._truncateToN(new BN(msg, 16));
          key = this.keyFromPublic(key, enc);
          signature = new Signature(signature, "hex");
          var r = signature.r;
          var s = signature.s;
          if (r.cmpn(1) < 0 || r.cmp(this.n) >= 0) return false;
          if (s.cmpn(1) < 0 || s.cmp(this.n) >= 0) return false;
          var sinv = s.invm(this.n);
          var u1 = sinv.mul(msg).umod(this.n);
          var u2 = sinv.mul(r).umod(this.n);
          var p;
          if (!this.curve._maxwellTrick) {
            p = this.g.mulAdd(u1, key.getPublic(), u2);
            if (p.isInfinity()) return false;
            return p.getX().umod(this.n).cmp(r) === 0;
          }
          p = this.g.jmulAdd(u1, key.getPublic(), u2);
          if (p.isInfinity()) return false;
          return p.eqXToP(r);
        };
        EC.prototype.recoverPubKey = function (msg, signature, j, enc) {
          assert((3 & j) === j, "The recovery param is more than two bits");
          signature = new Signature(signature, enc);
          var n = this.n;
          var e = new BN(msg);
          var r = signature.r;
          var s = signature.s;
          var isYOdd = j & 1;
          var isSecondKey = j >> 1;
          if (r.cmp(this.curve.p.umod(this.curve.n)) >= 0 && isSecondKey)
            throw new Error("Unable to find sencond key candinate");
          if (isSecondKey)
            r = this.curve.pointFromX(r.add(this.curve.n), isYOdd);
          else r = this.curve.pointFromX(r, isYOdd);
          var rInv = signature.r.invm(n);
          var s1 = n.sub(e).mul(rInv).umod(n);
          var s2 = s.mul(rInv).umod(n);
          return this.g.mulAdd(s1, r, s2);
        };
        EC.prototype.getKeyRecoveryParam = function (e, signature, Q, enc) {
          signature = new Signature(signature, enc);
          if (signature.recoveryParam !== null) return signature.recoveryParam;
          for (var i = 0; i < 4; i++) {
            var Qprime;
            try {
              Qprime = this.recoverPubKey(e, signature, i);
            } catch (e) {
              continue;
            }
            if (Qprime.eq(Q)) return i;
          }
          throw new Error("Unable to find valid recovery factor");
        };
      },
      {
        "../curves": 34,
        "../utils": 42,
        "./key": 36,
        "./signature": 37,
        "bn.js": 43,
        brorand: 23,
        "hmac-drbg": 92,
      },
    ],
    36: [
      function (require, module, exports) {
        "use strict";
        var BN = require("bn.js");
        var utils = require("../utils");
        var assert = utils.assert;
        function KeyPair(ec, options) {
          this.ec = ec;
          this.priv = null;
          this.pub = null;
          if (options.priv) this._importPrivate(options.priv, options.privEnc);
          if (options.pub) this._importPublic(options.pub, options.pubEnc);
        }
        module.exports = KeyPair;
        KeyPair.fromPublic = function fromPublic(ec, pub, enc) {
          if (pub instanceof KeyPair) return pub;
          return new KeyPair(ec, { pub: pub, pubEnc: enc });
        };
        KeyPair.fromPrivate = function fromPrivate(ec, priv, enc) {
          if (priv instanceof KeyPair) return priv;
          return new KeyPair(ec, { priv: priv, privEnc: enc });
        };
        KeyPair.prototype.validate = function validate() {
          var pub = this.getPublic();
          if (pub.isInfinity())
            return { result: false, reason: "Invalid public key" };
          if (!pub.validate())
            return { result: false, reason: "Public key is not a point" };
          if (!pub.mul(this.ec.curve.n).isInfinity())
            return { result: false, reason: "Public key * N != O" };
          return { result: true, reason: null };
        };
        KeyPair.prototype.getPublic = function getPublic(compact, enc) {
          if (typeof compact === "string") {
            enc = compact;
            compact = null;
          }
          if (!this.pub) this.pub = this.ec.g.mul(this.priv);
          if (!enc) return this.pub;
          return this.pub.encode(enc, compact);
        };
        KeyPair.prototype.getPrivate = function getPrivate(enc) {
          if (enc === "hex") return this.priv.toString(16, 2);
          else return this.priv;
        };
        KeyPair.prototype._importPrivate = function _importPrivate(key, enc) {
          this.priv = new BN(key, enc || 16);
          this.priv = this.priv.umod(this.ec.curve.n);
        };
        KeyPair.prototype._importPublic = function _importPublic(key, enc) {
          if (key.x || key.y) {
            if (this.ec.curve.type === "mont") {
              assert(key.x, "Need x coordinate");
            } else if (
              this.ec.curve.type === "short" ||
              this.ec.curve.type === "edwards"
            ) {
              assert(key.x && key.y, "Need both x and y coordinate");
            }
            this.pub = this.ec.curve.point(key.x, key.y);
            return;
          }
          this.pub = this.ec.curve.decodePoint(key, enc);
        };
        KeyPair.prototype.derive = function derive(pub) {
          if (!pub.validate()) {
            assert(pub.validate(), "public point not validated");
          }
          return pub.mul(this.priv).getX();
        };
        KeyPair.prototype.sign = function sign(msg, enc, options) {
          return this.ec.sign(msg, this, enc, options);
        };
        KeyPair.prototype.verify = function verify(msg, signature) {
          return this.ec.verify(msg, signature, this);
        };
        KeyPair.prototype.inspect = function inspect() {
          return (
            "<Key priv: " +
            (this.priv && this.priv.toString(16, 2)) +
            " pub: " +
            (this.pub && this.pub.inspect()) +
            " >"
          );
        };
      },
      { "../utils": 42, "bn.js": 43 },
    ],
    37: [
      function (require, module, exports) {
        "use strict";
        var BN = require("bn.js");
        var utils = require("../utils");
        var assert = utils.assert;
        function Signature(options, enc) {
          if (options instanceof Signature) return options;
          if (this._importDER(options, enc)) return;
          assert(options.r && options.s, "Signature without r or s");
          this.r = new BN(options.r, 16);
          this.s = new BN(options.s, 16);
          if (options.recoveryParam === undefined) this.recoveryParam = null;
          else this.recoveryParam = options.recoveryParam;
        }
        module.exports = Signature;
        function Position() {
          this.place = 0;
        }
        function getLength(buf, p) {
          var initial = buf[p.place++];
          if (!(initial & 128)) {
            return initial;
          }
          var octetLen = initial & 15;
          if (octetLen === 0 || octetLen > 4) {
            return false;
          }
          var val = 0;
          for (var i = 0, off = p.place; i < octetLen; i++, off++) {
            val <<= 8;
            val |= buf[off];
            val >>>= 0;
          }
          if (val <= 127) {
            return false;
          }
          p.place = off;
          return val;
        }
        function rmPadding(buf) {
          var i = 0;
          var len = buf.length - 1;
          while (!buf[i] && !(buf[i + 1] & 128) && i < len) {
            i++;
          }
          if (i === 0) {
            return buf;
          }
          return buf.slice(i);
        }
        Signature.prototype._importDER = function _importDER(data, enc) {
          data = utils.toArray(data, enc);
          var p = new Position();
          if (data[p.place++] !== 48) {
            return false;
          }
          var len = getLength(data, p);
          if (len === false) {
            return false;
          }
          if (len + p.place !== data.length) {
            return false;
          }
          if (data[p.place++] !== 2) {
            return false;
          }
          var rlen = getLength(data, p);
          if (rlen === false) {
            return false;
          }
          var r = data.slice(p.place, rlen + p.place);
          p.place += rlen;
          if (data[p.place++] !== 2) {
            return false;
          }
          var slen = getLength(data, p);
          if (slen === false) {
            return false;
          }
          if (data.length !== slen + p.place) {
            return false;
          }
          var s = data.slice(p.place, slen + p.place);
          if (r[0] === 0) {
            if (r[1] & 128) {
              r = r.slice(1);
            } else {
              return false;
            }
          }
          if (s[0] === 0) {
            if (s[1] & 128) {
              s = s.slice(1);
            } else {
              return false;
            }
          }
          this.r = new BN(r);
          this.s = new BN(s);
          this.recoveryParam = null;
          return true;
        };
        function constructLength(arr, len) {
          if (len < 128) {
            arr.push(len);
            return;
          }
          var octets = 1 + ((Math.log(len) / Math.LN2) >>> 3);
          arr.push(octets | 128);
          while (--octets) {
            arr.push((len >>> (octets << 3)) & 255);
          }
          arr.push(len);
        }
        Signature.prototype.toDER = function toDER(enc) {
          var r = this.r.toArray();
          var s = this.s.toArray();
          if (r[0] & 128) r = [0].concat(r);
          if (s[0] & 128) s = [0].concat(s);
          r = rmPadding(r);
          s = rmPadding(s);
          while (!s[0] && !(s[1] & 128)) {
            s = s.slice(1);
          }
          var arr = [2];
          constructLength(arr, r.length);
          arr = arr.concat(r);
          arr.push(2);
          constructLength(arr, s.length);
          var backHalf = arr.concat(s);
          var res = [48];
          constructLength(res, backHalf.length);
          res = res.concat(backHalf);
          return utils.encode(res, enc);
        };
      },
      { "../utils": 42, "bn.js": 43 },
    ],
    38: [
      function (require, module, exports) {
        "use strict";
        var hash = require("hash.js");
        var curves = require("../curves");
        var utils = require("../utils");
        var assert = utils.assert;
        var parseBytes = utils.parseBytes;
        var KeyPair = require("./key");
        var Signature = require("./signature");
        function EDDSA(curve) {
          assert(curve === "ed25519", "only tested with ed25519 so far");
          if (!(this instanceof EDDSA)) return new EDDSA(curve);
          curve = curves[curve].curve;
          this.curve = curve;
          this.g = curve.g;
          this.g.precompute(curve.n.bitLength() + 1);
          this.pointClass = curve.point().constructor;
          this.encodingLength = Math.ceil(curve.n.bitLength() / 8);
          this.hash = hash.sha512;
        }
        module.exports = EDDSA;
        EDDSA.prototype.sign = function sign(message, secret) {
          message = parseBytes(message);
          var key = this.keyFromSecret(secret);
          var r = this.hashInt(key.messagePrefix(), message);
          var R = this.g.mul(r);
          var Rencoded = this.encodePoint(R);
          var s_ = this.hashInt(Rencoded, key.pubBytes(), message).mul(
            key.priv()
          );
          var S = r.add(s_).umod(this.curve.n);
          return this.makeSignature({ R: R, S: S, Rencoded: Rencoded });
        };
        EDDSA.prototype.verify = function verify(message, sig, pub) {
          message = parseBytes(message);
          sig = this.makeSignature(sig);
          var key = this.keyFromPublic(pub);
          var h = this.hashInt(sig.Rencoded(), key.pubBytes(), message);
          var SG = this.g.mul(sig.S());
          var RplusAh = sig.R().add(key.pub().mul(h));
          return RplusAh.eq(SG);
        };
        EDDSA.prototype.hashInt = function hashInt() {
          var hash = this.hash();
          for (var i = 0; i < arguments.length; i++) hash.update(arguments[i]);
          return utils.intFromLE(hash.digest()).umod(this.curve.n);
        };
        EDDSA.prototype.keyFromPublic = function keyFromPublic(pub) {
          return KeyPair.fromPublic(this, pub);
        };
        EDDSA.prototype.keyFromSecret = function keyFromSecret(secret) {
          return KeyPair.fromSecret(this, secret);
        };
        EDDSA.prototype.makeSignature = function makeSignature(sig) {
          if (sig instanceof Signature) return sig;
          return new Signature(this, sig);
        };
        EDDSA.prototype.encodePoint = function encodePoint(point) {
          var enc = point.getY().toArray("le", this.encodingLength);
          enc[this.encodingLength - 1] |= point.getX().isOdd() ? 128 : 0;
          return enc;
        };
        EDDSA.prototype.decodePoint = function decodePoint(bytes) {
          bytes = utils.parseBytes(bytes);
          var lastIx = bytes.length - 1;
          var normed = bytes.slice(0, lastIx).concat(bytes[lastIx] & ~128);
          var xIsOdd = (bytes[lastIx] & 128) !== 0;
          var y = utils.intFromLE(normed);
          return this.curve.pointFromY(y, xIsOdd);
        };
        EDDSA.prototype.encodeInt = function encodeInt(num) {
          return num.toArray("le", this.encodingLength);
        };
        EDDSA.prototype.decodeInt = function decodeInt(bytes) {
          return utils.intFromLE(bytes);
        };
        EDDSA.prototype.isPoint = function isPoint(val) {
          return val instanceof this.pointClass;
        };
      },
      {
        "../curves": 34,
        "../utils": 42,
        "./key": 39,
        "./signature": 40,
        "hash.js": 80,
      },
    ],
    39: [
      function (require, module, exports) {
        "use strict";
        var utils = require("../utils");
        var assert = utils.assert;
        var parseBytes = utils.parseBytes;
        var cachedProperty = utils.cachedProperty;
        function KeyPair(eddsa, params) {
          this.eddsa = eddsa;
          this._secret = parseBytes(params.secret);
          if (eddsa.isPoint(params.pub)) this._pub = params.pub;
          else this._pubBytes = parseBytes(params.pub);
        }
        KeyPair.fromPublic = function fromPublic(eddsa, pub) {
          if (pub instanceof KeyPair) return pub;
          return new KeyPair(eddsa, { pub: pub });
        };
        KeyPair.fromSecret = function fromSecret(eddsa, secret) {
          if (secret instanceof KeyPair) return secret;
          return new KeyPair(eddsa, { secret: secret });
        };
        KeyPair.prototype.secret = function secret() {
          return this._secret;
        };
        cachedProperty(KeyPair, "pubBytes", function pubBytes() {
          return this.eddsa.encodePoint(this.pub());
        });
        cachedProperty(KeyPair, "pub", function pub() {
          if (this._pubBytes) return this.eddsa.decodePoint(this._pubBytes);
          return this.eddsa.g.mul(this.priv());
        });
        cachedProperty(KeyPair, "privBytes", function privBytes() {
          var eddsa = this.eddsa;
          var hash = this.hash();
          var lastIx = eddsa.encodingLength - 1;
          var a = hash.slice(0, eddsa.encodingLength);
          a[0] &= 248;
          a[lastIx] &= 127;
          a[lastIx] |= 64;
          return a;
        });
        cachedProperty(KeyPair, "priv", function priv() {
          return this.eddsa.decodeInt(this.privBytes());
        });
        cachedProperty(KeyPair, "hash", function hash() {
          return this.eddsa.hash().update(this.secret()).digest();
        });
        cachedProperty(KeyPair, "messagePrefix", function messagePrefix() {
          return this.hash().slice(this.eddsa.encodingLength);
        });
        KeyPair.prototype.sign = function sign(message) {
          assert(this._secret, "KeyPair can only verify");
          return this.eddsa.sign(message, this);
        };
        KeyPair.prototype.verify = function verify(message, sig) {
          return this.eddsa.verify(message, sig, this);
        };
        KeyPair.prototype.getSecret = function getSecret(enc) {
          assert(this._secret, "KeyPair is public only");
          return utils.encode(this.secret(), enc);
        };
        KeyPair.prototype.getPublic = function getPublic(enc) {
          return utils.encode(this.pubBytes(), enc);
        };
        module.exports = KeyPair;
      },
      { "../utils": 42 },
    ],
    40: [
      function (require, module, exports) {
        "use strict";
        var BN = require("bn.js");
        var utils = require("../utils");
        var assert = utils.assert;
        var cachedProperty = utils.cachedProperty;
        var parseBytes = utils.parseBytes;
        function Signature(eddsa, sig) {
          this.eddsa = eddsa;
          if (typeof sig !== "object") sig = parseBytes(sig);
          if (Array.isArray(sig)) {
            sig = {
              R: sig.slice(0, eddsa.encodingLength),
              S: sig.slice(eddsa.encodingLength),
            };
          }
          assert(sig.R && sig.S, "Signature without R or S");
          if (eddsa.isPoint(sig.R)) this._R = sig.R;
          if (sig.S instanceof BN) this._S = sig.S;
          this._Rencoded = Array.isArray(sig.R) ? sig.R : sig.Rencoded;
          this._Sencoded = Array.isArray(sig.S) ? sig.S : sig.Sencoded;
        }
        cachedProperty(Signature, "S", function S() {
          return this.eddsa.decodeInt(this.Sencoded());
        });
        cachedProperty(Signature, "R", function R() {
          return this.eddsa.decodePoint(this.Rencoded());
        });
        cachedProperty(Signature, "Rencoded", function Rencoded() {
          return this.eddsa.encodePoint(this.R());
        });
        cachedProperty(Signature, "Sencoded", function Sencoded() {
          return this.eddsa.encodeInt(this.S());
        });
        Signature.prototype.toBytes = function toBytes() {
          return this.Rencoded().concat(this.Sencoded());
        };
        Signature.prototype.toHex = function toHex() {
          return utils.encode(this.toBytes(), "hex").toUpperCase();
        };
        module.exports = Signature;
      },
      { "../utils": 42, "bn.js": 43 },
    ],
    41: [
      function (require, module, exports) {
        module.exports = {
          doubles: {
            step: 4,
            points: [
              [
                "e60fce93b59e9ec53011aabc21c23e97b2a31369b87a5ae9c44ee89e2a6dec0a",
                "f7e3507399e595929db99f34f57937101296891e44d23f0be1f32cce69616821",
              ],
              [
                "8282263212c609d9ea2a6e3e172de238d8c39cabd5ac1ca10646e23fd5f51508",
                "11f8a8098557dfe45e8256e830b60ace62d613ac2f7b17bed31b6eaff6e26caf",
              ],
              [
                "175e159f728b865a72f99cc6c6fc846de0b93833fd2222ed73fce5b551e5b739",
                "d3506e0d9e3c79eba4ef97a51ff71f5eacb5955add24345c6efa6ffee9fed695",
              ],
              [
                "363d90d447b00c9c99ceac05b6262ee053441c7e55552ffe526bad8f83ff4640",
                "4e273adfc732221953b445397f3363145b9a89008199ecb62003c7f3bee9de9",
              ],
              [
                "8b4b5f165df3c2be8c6244b5b745638843e4a781a15bcd1b69f79a55dffdf80c",
                "4aad0a6f68d308b4b3fbd7813ab0da04f9e336546162ee56b3eff0c65fd4fd36",
              ],
              [
                "723cbaa6e5db996d6bf771c00bd548c7b700dbffa6c0e77bcb6115925232fcda",
                "96e867b5595cc498a921137488824d6e2660a0653779494801dc069d9eb39f5f",
              ],
              [
                "eebfa4d493bebf98ba5feec812c2d3b50947961237a919839a533eca0e7dd7fa",
                "5d9a8ca3970ef0f269ee7edaf178089d9ae4cdc3a711f712ddfd4fdae1de8999",
              ],
              [
                "100f44da696e71672791d0a09b7bde459f1215a29b3c03bfefd7835b39a48db0",
                "cdd9e13192a00b772ec8f3300c090666b7ff4a18ff5195ac0fbd5cd62bc65a09",
              ],
              [
                "e1031be262c7ed1b1dc9227a4a04c017a77f8d4464f3b3852c8acde6e534fd2d",
                "9d7061928940405e6bb6a4176597535af292dd419e1ced79a44f18f29456a00d",
              ],
              [
                "feea6cae46d55b530ac2839f143bd7ec5cf8b266a41d6af52d5e688d9094696d",
                "e57c6b6c97dce1bab06e4e12bf3ecd5c981c8957cc41442d3155debf18090088",
              ],
              [
                "da67a91d91049cdcb367be4be6ffca3cfeed657d808583de33fa978bc1ec6cb1",
                "9bacaa35481642bc41f463f7ec9780e5dec7adc508f740a17e9ea8e27a68be1d",
              ],
              [
                "53904faa0b334cdda6e000935ef22151ec08d0f7bb11069f57545ccc1a37b7c0",
                "5bc087d0bc80106d88c9eccac20d3c1c13999981e14434699dcb096b022771c8",
              ],
              [
                "8e7bcd0bd35983a7719cca7764ca906779b53a043a9b8bcaeff959f43ad86047",
                "10b7770b2a3da4b3940310420ca9514579e88e2e47fd68b3ea10047e8460372a",
              ],
              [
                "385eed34c1cdff21e6d0818689b81bde71a7f4f18397e6690a841e1599c43862",
                "283bebc3e8ea23f56701de19e9ebf4576b304eec2086dc8cc0458fe5542e5453",
              ],
              [
                "6f9d9b803ecf191637c73a4413dfa180fddf84a5947fbc9c606ed86c3fac3a7",
                "7c80c68e603059ba69b8e2a30e45c4d47ea4dd2f5c281002d86890603a842160",
              ],
              [
                "3322d401243c4e2582a2147c104d6ecbf774d163db0f5e5313b7e0e742d0e6bd",
                "56e70797e9664ef5bfb019bc4ddaf9b72805f63ea2873af624f3a2e96c28b2a0",
              ],
              [
                "85672c7d2de0b7da2bd1770d89665868741b3f9af7643397721d74d28134ab83",
                "7c481b9b5b43b2eb6374049bfa62c2e5e77f17fcc5298f44c8e3094f790313a6",
              ],
              [
                "948bf809b1988a46b06c9f1919413b10f9226c60f668832ffd959af60c82a0a",
                "53a562856dcb6646dc6b74c5d1c3418c6d4dff08c97cd2bed4cb7f88d8c8e589",
              ],
              [
                "6260ce7f461801c34f067ce0f02873a8f1b0e44dfc69752accecd819f38fd8e8",
                "bc2da82b6fa5b571a7f09049776a1ef7ecd292238051c198c1a84e95b2b4ae17",
              ],
              [
                "e5037de0afc1d8d43d8348414bbf4103043ec8f575bfdc432953cc8d2037fa2d",
                "4571534baa94d3b5f9f98d09fb990bddbd5f5b03ec481f10e0e5dc841d755bda",
              ],
              [
                "e06372b0f4a207adf5ea905e8f1771b4e7e8dbd1c6a6c5b725866a0ae4fce725",
                "7a908974bce18cfe12a27bb2ad5a488cd7484a7787104870b27034f94eee31dd",
              ],
              [
                "213c7a715cd5d45358d0bbf9dc0ce02204b10bdde2a3f58540ad6908d0559754",
                "4b6dad0b5ae462507013ad06245ba190bb4850f5f36a7eeddff2c27534b458f2",
              ],
              [
                "4e7c272a7af4b34e8dbb9352a5419a87e2838c70adc62cddf0cc3a3b08fbd53c",
                "17749c766c9d0b18e16fd09f6def681b530b9614bff7dd33e0b3941817dcaae6",
              ],
              [
                "fea74e3dbe778b1b10f238ad61686aa5c76e3db2be43057632427e2840fb27b6",
                "6e0568db9b0b13297cf674deccb6af93126b596b973f7b77701d3db7f23cb96f",
              ],
              [
                "76e64113f677cf0e10a2570d599968d31544e179b760432952c02a4417bdde39",
                "c90ddf8dee4e95cf577066d70681f0d35e2a33d2b56d2032b4b1752d1901ac01",
              ],
              [
                "c738c56b03b2abe1e8281baa743f8f9a8f7cc643df26cbee3ab150242bcbb891",
                "893fb578951ad2537f718f2eacbfbbbb82314eef7880cfe917e735d9699a84c3",
              ],
              [
                "d895626548b65b81e264c7637c972877d1d72e5f3a925014372e9f6588f6c14b",
                "febfaa38f2bc7eae728ec60818c340eb03428d632bb067e179363ed75d7d991f",
              ],
              [
                "b8da94032a957518eb0f6433571e8761ceffc73693e84edd49150a564f676e03",
                "2804dfa44805a1e4d7c99cc9762808b092cc584d95ff3b511488e4e74efdf6e7",
              ],
              [
                "e80fea14441fb33a7d8adab9475d7fab2019effb5156a792f1a11778e3c0df5d",
                "eed1de7f638e00771e89768ca3ca94472d155e80af322ea9fcb4291b6ac9ec78",
              ],
              [
                "a301697bdfcd704313ba48e51d567543f2a182031efd6915ddc07bbcc4e16070",
                "7370f91cfb67e4f5081809fa25d40f9b1735dbf7c0a11a130c0d1a041e177ea1",
              ],
              [
                "90ad85b389d6b936463f9d0512678de208cc330b11307fffab7ac63e3fb04ed4",
                "e507a3620a38261affdcbd9427222b839aefabe1582894d991d4d48cb6ef150",
              ],
              [
                "8f68b9d2f63b5f339239c1ad981f162ee88c5678723ea3351b7b444c9ec4c0da",
                "662a9f2dba063986de1d90c2b6be215dbbea2cfe95510bfdf23cbf79501fff82",
              ],
              [
                "e4f3fb0176af85d65ff99ff9198c36091f48e86503681e3e6686fd5053231e11",
                "1e63633ad0ef4f1c1661a6d0ea02b7286cc7e74ec951d1c9822c38576feb73bc",
              ],
              [
                "8c00fa9b18ebf331eb961537a45a4266c7034f2f0d4e1d0716fb6eae20eae29e",
                "efa47267fea521a1a9dc343a3736c974c2fadafa81e36c54e7d2a4c66702414b",
              ],
              [
                "e7a26ce69dd4829f3e10cec0a9e98ed3143d084f308b92c0997fddfc60cb3e41",
                "2a758e300fa7984b471b006a1aafbb18d0a6b2c0420e83e20e8a9421cf2cfd51",
              ],
              [
                "b6459e0ee3662ec8d23540c223bcbdc571cbcb967d79424f3cf29eb3de6b80ef",
                "67c876d06f3e06de1dadf16e5661db3c4b3ae6d48e35b2ff30bf0b61a71ba45",
              ],
              [
                "d68a80c8280bb840793234aa118f06231d6f1fc67e73c5a5deda0f5b496943e8",
                "db8ba9fff4b586d00c4b1f9177b0e28b5b0e7b8f7845295a294c84266b133120",
              ],
              [
                "324aed7df65c804252dc0270907a30b09612aeb973449cea4095980fc28d3d5d",
                "648a365774b61f2ff130c0c35aec1f4f19213b0c7e332843967224af96ab7c84",
              ],
              [
                "4df9c14919cde61f6d51dfdbe5fee5dceec4143ba8d1ca888e8bd373fd054c96",
                "35ec51092d8728050974c23a1d85d4b5d506cdc288490192ebac06cad10d5d",
              ],
              [
                "9c3919a84a474870faed8a9c1cc66021523489054d7f0308cbfc99c8ac1f98cd",
                "ddb84f0f4a4ddd57584f044bf260e641905326f76c64c8e6be7e5e03d4fc599d",
              ],
              [
                "6057170b1dd12fdf8de05f281d8e06bb91e1493a8b91d4cc5a21382120a959e5",
                "9a1af0b26a6a4807add9a2daf71df262465152bc3ee24c65e899be932385a2a8",
              ],
              [
                "a576df8e23a08411421439a4518da31880cef0fba7d4df12b1a6973eecb94266",
                "40a6bf20e76640b2c92b97afe58cd82c432e10a7f514d9f3ee8be11ae1b28ec8",
              ],
              [
                "7778a78c28dec3e30a05fe9629de8c38bb30d1f5cf9a3a208f763889be58ad71",
                "34626d9ab5a5b22ff7098e12f2ff580087b38411ff24ac563b513fc1fd9f43ac",
              ],
              [
                "928955ee637a84463729fd30e7afd2ed5f96274e5ad7e5cb09eda9c06d903ac",
                "c25621003d3f42a827b78a13093a95eeac3d26efa8a8d83fc5180e935bcd091f",
              ],
              [
                "85d0fef3ec6db109399064f3a0e3b2855645b4a907ad354527aae75163d82751",
                "1f03648413a38c0be29d496e582cf5663e8751e96877331582c237a24eb1f962",
              ],
              [
                "ff2b0dce97eece97c1c9b6041798b85dfdfb6d8882da20308f5404824526087e",
                "493d13fef524ba188af4c4dc54d07936c7b7ed6fb90e2ceb2c951e01f0c29907",
              ],
              [
                "827fbbe4b1e880ea9ed2b2e6301b212b57f1ee148cd6dd28780e5e2cf856e241",
                "c60f9c923c727b0b71bef2c67d1d12687ff7a63186903166d605b68baec293ec",
              ],
              [
                "eaa649f21f51bdbae7be4ae34ce6e5217a58fdce7f47f9aa7f3b58fa2120e2b3",
                "be3279ed5bbbb03ac69a80f89879aa5a01a6b965f13f7e59d47a5305ba5ad93d",
              ],
              [
                "e4a42d43c5cf169d9391df6decf42ee541b6d8f0c9a137401e23632dda34d24f",
                "4d9f92e716d1c73526fc99ccfb8ad34ce886eedfa8d8e4f13a7f7131deba9414",
              ],
              [
                "1ec80fef360cbdd954160fadab352b6b92b53576a88fea4947173b9d4300bf19",
                "aeefe93756b5340d2f3a4958a7abbf5e0146e77f6295a07b671cdc1cc107cefd",
              ],
              [
                "146a778c04670c2f91b00af4680dfa8bce3490717d58ba889ddb5928366642be",
                "b318e0ec3354028add669827f9d4b2870aaa971d2f7e5ed1d0b297483d83efd0",
              ],
              [
                "fa50c0f61d22e5f07e3acebb1aa07b128d0012209a28b9776d76a8793180eef9",
                "6b84c6922397eba9b72cd2872281a68a5e683293a57a213b38cd8d7d3f4f2811",
              ],
              [
                "da1d61d0ca721a11b1a5bf6b7d88e8421a288ab5d5bba5220e53d32b5f067ec2",
                "8157f55a7c99306c79c0766161c91e2966a73899d279b48a655fba0f1ad836f1",
              ],
              [
                "a8e282ff0c9706907215ff98e8fd416615311de0446f1e062a73b0610d064e13",
                "7f97355b8db81c09abfb7f3c5b2515888b679a3e50dd6bd6cef7c73111f4cc0c",
              ],
              [
                "174a53b9c9a285872d39e56e6913cab15d59b1fa512508c022f382de8319497c",
                "ccc9dc37abfc9c1657b4155f2c47f9e6646b3a1d8cb9854383da13ac079afa73",
              ],
              [
                "959396981943785c3d3e57edf5018cdbe039e730e4918b3d884fdff09475b7ba",
                "2e7e552888c331dd8ba0386a4b9cd6849c653f64c8709385e9b8abf87524f2fd",
              ],
              [
                "d2a63a50ae401e56d645a1153b109a8fcca0a43d561fba2dbb51340c9d82b151",
                "e82d86fb6443fcb7565aee58b2948220a70f750af484ca52d4142174dcf89405",
              ],
              [
                "64587e2335471eb890ee7896d7cfdc866bacbdbd3839317b3436f9b45617e073",
                "d99fcdd5bf6902e2ae96dd6447c299a185b90a39133aeab358299e5e9faf6589",
              ],
              [
                "8481bde0e4e4d885b3a546d3e549de042f0aa6cea250e7fd358d6c86dd45e458",
                "38ee7b8cba5404dd84a25bf39cecb2ca900a79c42b262e556d64b1b59779057e",
              ],
              [
                "13464a57a78102aa62b6979ae817f4637ffcfed3c4b1ce30bcd6303f6caf666b",
                "69be159004614580ef7e433453ccb0ca48f300a81d0942e13f495a907f6ecc27",
              ],
              [
                "bc4a9df5b713fe2e9aef430bcc1dc97a0cd9ccede2f28588cada3a0d2d83f366",
                "d3a81ca6e785c06383937adf4b798caa6e8a9fbfa547b16d758d666581f33c1",
              ],
              [
                "8c28a97bf8298bc0d23d8c749452a32e694b65e30a9472a3954ab30fe5324caa",
                "40a30463a3305193378fedf31f7cc0eb7ae784f0451cb9459e71dc73cbef9482",
              ],
              [
                "8ea9666139527a8c1dd94ce4f071fd23c8b350c5a4bb33748c4ba111faccae0",
                "620efabbc8ee2782e24e7c0cfb95c5d735b783be9cf0f8e955af34a30e62b945",
              ],
              [
                "dd3625faef5ba06074669716bbd3788d89bdde815959968092f76cc4eb9a9787",
                "7a188fa3520e30d461da2501045731ca941461982883395937f68d00c644a573",
              ],
              [
                "f710d79d9eb962297e4f6232b40e8f7feb2bc63814614d692c12de752408221e",
                "ea98e67232d3b3295d3b535532115ccac8612c721851617526ae47a9c77bfc82",
              ],
            ],
          },
          naf: {
            wnd: 7,
            points: [
              [
                "f9308a019258c31049344f85f89d5229b531c845836f99b08601f113bce036f9",
                "388f7b0f632de8140fe337e62a37f3566500a99934c2231b6cb9fd7584b8e672",
              ],
              [
                "2f8bde4d1a07209355b4a7250a5c5128e88b84bddc619ab7cba8d569b240efe4",
                "d8ac222636e5e3d6d4dba9dda6c9c426f788271bab0d6840dca87d3aa6ac62d6",
              ],
              [
                "5cbdf0646e5db4eaa398f365f2ea7a0e3d419b7e0330e39ce92bddedcac4f9bc",
                "6aebca40ba255960a3178d6d861a54dba813d0b813fde7b5a5082628087264da",
              ],
              [
                "acd484e2f0c7f65309ad178a9f559abde09796974c57e714c35f110dfc27ccbe",
                "cc338921b0a7d9fd64380971763b61e9add888a4375f8e0f05cc262ac64f9c37",
              ],
              [
                "774ae7f858a9411e5ef4246b70c65aac5649980be5c17891bbec17895da008cb",
                "d984a032eb6b5e190243dd56d7b7b365372db1e2dff9d6a8301d74c9c953c61b",
              ],
              [
                "f28773c2d975288bc7d1d205c3748651b075fbc6610e58cddeeddf8f19405aa8",
                "ab0902e8d880a89758212eb65cdaf473a1a06da521fa91f29b5cb52db03ed81",
              ],
              [
                "d7924d4f7d43ea965a465ae3095ff41131e5946f3c85f79e44adbcf8e27e080e",
                "581e2872a86c72a683842ec228cc6defea40af2bd896d3a5c504dc9ff6a26b58",
              ],
              [
                "defdea4cdb677750a420fee807eacf21eb9898ae79b9768766e4faa04a2d4a34",
                "4211ab0694635168e997b0ead2a93daeced1f4a04a95c0f6cfb199f69e56eb77",
              ],
              [
                "2b4ea0a797a443d293ef5cff444f4979f06acfebd7e86d277475656138385b6c",
                "85e89bc037945d93b343083b5a1c86131a01f60c50269763b570c854e5c09b7a",
              ],
              [
                "352bbf4a4cdd12564f93fa332ce333301d9ad40271f8107181340aef25be59d5",
                "321eb4075348f534d59c18259dda3e1f4a1b3b2e71b1039c67bd3d8bcf81998c",
              ],
              [
                "2fa2104d6b38d11b0230010559879124e42ab8dfeff5ff29dc9cdadd4ecacc3f",
                "2de1068295dd865b64569335bd5dd80181d70ecfc882648423ba76b532b7d67",
              ],
              [
                "9248279b09b4d68dab21a9b066edda83263c3d84e09572e269ca0cd7f5453714",
                "73016f7bf234aade5d1aa71bdea2b1ff3fc0de2a887912ffe54a32ce97cb3402",
              ],
              [
                "daed4f2be3a8bf278e70132fb0beb7522f570e144bf615c07e996d443dee8729",
                "a69dce4a7d6c98e8d4a1aca87ef8d7003f83c230f3afa726ab40e52290be1c55",
              ],
              [
                "c44d12c7065d812e8acf28d7cbb19f9011ecd9e9fdf281b0e6a3b5e87d22e7db",
                "2119a460ce326cdc76c45926c982fdac0e106e861edf61c5a039063f0e0e6482",
              ],
              [
                "6a245bf6dc698504c89a20cfded60853152b695336c28063b61c65cbd269e6b4",
                "e022cf42c2bd4a708b3f5126f16a24ad8b33ba48d0423b6efd5e6348100d8a82",
              ],
              [
                "1697ffa6fd9de627c077e3d2fe541084ce13300b0bec1146f95ae57f0d0bd6a5",
                "b9c398f186806f5d27561506e4557433a2cf15009e498ae7adee9d63d01b2396",
              ],
              [
                "605bdb019981718b986d0f07e834cb0d9deb8360ffb7f61df982345ef27a7479",
                "2972d2de4f8d20681a78d93ec96fe23c26bfae84fb14db43b01e1e9056b8c49",
              ],
              [
                "62d14dab4150bf497402fdc45a215e10dcb01c354959b10cfe31c7e9d87ff33d",
                "80fc06bd8cc5b01098088a1950eed0db01aa132967ab472235f5642483b25eaf",
              ],
              [
                "80c60ad0040f27dade5b4b06c408e56b2c50e9f56b9b8b425e555c2f86308b6f",
                "1c38303f1cc5c30f26e66bad7fe72f70a65eed4cbe7024eb1aa01f56430bd57a",
              ],
              [
                "7a9375ad6167ad54aa74c6348cc54d344cc5dc9487d847049d5eabb0fa03c8fb",
                "d0e3fa9eca8726909559e0d79269046bdc59ea10c70ce2b02d499ec224dc7f7",
              ],
              [
                "d528ecd9b696b54c907a9ed045447a79bb408ec39b68df504bb51f459bc3ffc9",
                "eecf41253136e5f99966f21881fd656ebc4345405c520dbc063465b521409933",
              ],
              [
                "49370a4b5f43412ea25f514e8ecdad05266115e4a7ecb1387231808f8b45963",
                "758f3f41afd6ed428b3081b0512fd62a54c3f3afbb5b6764b653052a12949c9a",
              ],
              [
                "77f230936ee88cbbd73df930d64702ef881d811e0e1498e2f1c13eb1fc345d74",
                "958ef42a7886b6400a08266e9ba1b37896c95330d97077cbbe8eb3c7671c60d6",
              ],
              [
                "f2dac991cc4ce4b9ea44887e5c7c0bce58c80074ab9d4dbaeb28531b7739f530",
                "e0dedc9b3b2f8dad4da1f32dec2531df9eb5fbeb0598e4fd1a117dba703a3c37",
              ],
              [
                "463b3d9f662621fb1b4be8fbbe2520125a216cdfc9dae3debcba4850c690d45b",
                "5ed430d78c296c3543114306dd8622d7c622e27c970a1de31cb377b01af7307e",
              ],
              [
                "f16f804244e46e2a09232d4aff3b59976b98fac14328a2d1a32496b49998f247",
                "cedabd9b82203f7e13d206fcdf4e33d92a6c53c26e5cce26d6579962c4e31df6",
              ],
              [
                "caf754272dc84563b0352b7a14311af55d245315ace27c65369e15f7151d41d1",
                "cb474660ef35f5f2a41b643fa5e460575f4fa9b7962232a5c32f908318a04476",
              ],
              [
                "2600ca4b282cb986f85d0f1709979d8b44a09c07cb86d7c124497bc86f082120",
                "4119b88753c15bd6a693b03fcddbb45d5ac6be74ab5f0ef44b0be9475a7e4b40",
              ],
              [
                "7635ca72d7e8432c338ec53cd12220bc01c48685e24f7dc8c602a7746998e435",
                "91b649609489d613d1d5e590f78e6d74ecfc061d57048bad9e76f302c5b9c61",
              ],
              [
                "754e3239f325570cdbbf4a87deee8a66b7f2b33479d468fbc1a50743bf56cc18",
                "673fb86e5bda30fb3cd0ed304ea49a023ee33d0197a695d0c5d98093c536683",
              ],
              [
                "e3e6bd1071a1e96aff57859c82d570f0330800661d1c952f9fe2694691d9b9e8",
                "59c9e0bba394e76f40c0aa58379a3cb6a5a2283993e90c4167002af4920e37f5",
              ],
              [
                "186b483d056a033826ae73d88f732985c4ccb1f32ba35f4b4cc47fdcf04aa6eb",
                "3b952d32c67cf77e2e17446e204180ab21fb8090895138b4a4a797f86e80888b",
              ],
              [
                "df9d70a6b9876ce544c98561f4be4f725442e6d2b737d9c91a8321724ce0963f",
                "55eb2dafd84d6ccd5f862b785dc39d4ab157222720ef9da217b8c45cf2ba2417",
              ],
              [
                "5edd5cc23c51e87a497ca815d5dce0f8ab52554f849ed8995de64c5f34ce7143",
                "efae9c8dbc14130661e8cec030c89ad0c13c66c0d17a2905cdc706ab7399a868",
              ],
              [
                "290798c2b6476830da12fe02287e9e777aa3fba1c355b17a722d362f84614fba",
                "e38da76dcd440621988d00bcf79af25d5b29c094db2a23146d003afd41943e7a",
              ],
              [
                "af3c423a95d9f5b3054754efa150ac39cd29552fe360257362dfdecef4053b45",
                "f98a3fd831eb2b749a93b0e6f35cfb40c8cd5aa667a15581bc2feded498fd9c6",
              ],
              [
                "766dbb24d134e745cccaa28c99bf274906bb66b26dcf98df8d2fed50d884249a",
                "744b1152eacbe5e38dcc887980da38b897584a65fa06cedd2c924f97cbac5996",
              ],
              [
                "59dbf46f8c94759ba21277c33784f41645f7b44f6c596a58ce92e666191abe3e",
                "c534ad44175fbc300f4ea6ce648309a042ce739a7919798cd85e216c4a307f6e",
              ],
              [
                "f13ada95103c4537305e691e74e9a4a8dd647e711a95e73cb62dc6018cfd87b8",
                "e13817b44ee14de663bf4bc808341f326949e21a6a75c2570778419bdaf5733d",
              ],
              [
                "7754b4fa0e8aced06d4167a2c59cca4cda1869c06ebadfb6488550015a88522c",
                "30e93e864e669d82224b967c3020b8fa8d1e4e350b6cbcc537a48b57841163a2",
              ],
              [
                "948dcadf5990e048aa3874d46abef9d701858f95de8041d2a6828c99e2262519",
                "e491a42537f6e597d5d28a3224b1bc25df9154efbd2ef1d2cbba2cae5347d57e",
              ],
              [
                "7962414450c76c1689c7b48f8202ec37fb224cf5ac0bfa1570328a8a3d7c77ab",
                "100b610ec4ffb4760d5c1fc133ef6f6b12507a051f04ac5760afa5b29db83437",
              ],
              [
                "3514087834964b54b15b160644d915485a16977225b8847bb0dd085137ec47ca",
                "ef0afbb2056205448e1652c48e8127fc6039e77c15c2378b7e7d15a0de293311",
              ],
              [
                "d3cc30ad6b483e4bc79ce2c9dd8bc54993e947eb8df787b442943d3f7b527eaf",
                "8b378a22d827278d89c5e9be8f9508ae3c2ad46290358630afb34db04eede0a4",
              ],
              [
                "1624d84780732860ce1c78fcbfefe08b2b29823db913f6493975ba0ff4847610",
                "68651cf9b6da903e0914448c6cd9d4ca896878f5282be4c8cc06e2a404078575",
              ],
              [
                "733ce80da955a8a26902c95633e62a985192474b5af207da6df7b4fd5fc61cd4",
                "f5435a2bd2badf7d485a4d8b8db9fcce3e1ef8e0201e4578c54673bc1dc5ea1d",
              ],
              [
                "15d9441254945064cf1a1c33bbd3b49f8966c5092171e699ef258dfab81c045c",
                "d56eb30b69463e7234f5137b73b84177434800bacebfc685fc37bbe9efe4070d",
              ],
              [
                "a1d0fcf2ec9de675b612136e5ce70d271c21417c9d2b8aaaac138599d0717940",
                "edd77f50bcb5a3cab2e90737309667f2641462a54070f3d519212d39c197a629",
              ],
              [
                "e22fbe15c0af8ccc5780c0735f84dbe9a790badee8245c06c7ca37331cb36980",
                "a855babad5cd60c88b430a69f53a1a7a38289154964799be43d06d77d31da06",
              ],
              [
                "311091dd9860e8e20ee13473c1155f5f69635e394704eaa74009452246cfa9b3",
                "66db656f87d1f04fffd1f04788c06830871ec5a64feee685bd80f0b1286d8374",
              ],
              [
                "34c1fd04d301be89b31c0442d3e6ac24883928b45a9340781867d4232ec2dbdf",
                "9414685e97b1b5954bd46f730174136d57f1ceeb487443dc5321857ba73abee",
              ],
              [
                "f219ea5d6b54701c1c14de5b557eb42a8d13f3abbcd08affcc2a5e6b049b8d63",
                "4cb95957e83d40b0f73af4544cccf6b1f4b08d3c07b27fb8d8c2962a400766d1",
              ],
              [
                "d7b8740f74a8fbaab1f683db8f45de26543a5490bca627087236912469a0b448",
                "fa77968128d9c92ee1010f337ad4717eff15db5ed3c049b3411e0315eaa4593b",
              ],
              [
                "32d31c222f8f6f0ef86f7c98d3a3335ead5bcd32abdd94289fe4d3091aa824bf",
                "5f3032f5892156e39ccd3d7915b9e1da2e6dac9e6f26e961118d14b8462e1661",
              ],
              [
                "7461f371914ab32671045a155d9831ea8793d77cd59592c4340f86cbc18347b5",
                "8ec0ba238b96bec0cbdddcae0aa442542eee1ff50c986ea6b39847b3cc092ff6",
              ],
              [
                "ee079adb1df1860074356a25aa38206a6d716b2c3e67453d287698bad7b2b2d6",
                "8dc2412aafe3be5c4c5f37e0ecc5f9f6a446989af04c4e25ebaac479ec1c8c1e",
              ],
              [
                "16ec93e447ec83f0467b18302ee620f7e65de331874c9dc72bfd8616ba9da6b5",
                "5e4631150e62fb40d0e8c2a7ca5804a39d58186a50e497139626778e25b0674d",
              ],
              [
                "eaa5f980c245f6f038978290afa70b6bd8855897f98b6aa485b96065d537bd99",
                "f65f5d3e292c2e0819a528391c994624d784869d7e6ea67fb18041024edc07dc",
              ],
              [
                "78c9407544ac132692ee1910a02439958ae04877151342ea96c4b6b35a49f51",
                "f3e0319169eb9b85d5404795539a5e68fa1fbd583c064d2462b675f194a3ddb4",
              ],
              [
                "494f4be219a1a77016dcd838431aea0001cdc8ae7a6fc688726578d9702857a5",
                "42242a969283a5f339ba7f075e36ba2af925ce30d767ed6e55f4b031880d562c",
              ],
              [
                "a598a8030da6d86c6bc7f2f5144ea549d28211ea58faa70ebf4c1e665c1fe9b5",
                "204b5d6f84822c307e4b4a7140737aec23fc63b65b35f86a10026dbd2d864e6b",
              ],
              [
                "c41916365abb2b5d09192f5f2dbeafec208f020f12570a184dbadc3e58595997",
                "4f14351d0087efa49d245b328984989d5caf9450f34bfc0ed16e96b58fa9913",
              ],
              [
                "841d6063a586fa475a724604da03bc5b92a2e0d2e0a36acfe4c73a5514742881",
                "73867f59c0659e81904f9a1c7543698e62562d6744c169ce7a36de01a8d6154",
              ],
              [
                "5e95bb399a6971d376026947f89bde2f282b33810928be4ded112ac4d70e20d5",
                "39f23f366809085beebfc71181313775a99c9aed7d8ba38b161384c746012865",
              ],
              [
                "36e4641a53948fd476c39f8a99fd974e5ec07564b5315d8bf99471bca0ef2f66",
                "d2424b1b1abe4eb8164227b085c9aa9456ea13493fd563e06fd51cf5694c78fc",
              ],
              [
                "336581ea7bfbbb290c191a2f507a41cf5643842170e914faeab27c2c579f726",
                "ead12168595fe1be99252129b6e56b3391f7ab1410cd1e0ef3dcdcabd2fda224",
              ],
              [
                "8ab89816dadfd6b6a1f2634fcf00ec8403781025ed6890c4849742706bd43ede",
                "6fdcef09f2f6d0a044e654aef624136f503d459c3e89845858a47a9129cdd24e",
              ],
              [
                "1e33f1a746c9c5778133344d9299fcaa20b0938e8acff2544bb40284b8c5fb94",
                "60660257dd11b3aa9c8ed618d24edff2306d320f1d03010e33a7d2057f3b3b6",
              ],
              [
                "85b7c1dcb3cec1b7ee7f30ded79dd20a0ed1f4cc18cbcfcfa410361fd8f08f31",
                "3d98a9cdd026dd43f39048f25a8847f4fcafad1895d7a633c6fed3c35e999511",
              ],
              [
                "29df9fbd8d9e46509275f4b125d6d45d7fbe9a3b878a7af872a2800661ac5f51",
                "b4c4fe99c775a606e2d8862179139ffda61dc861c019e55cd2876eb2a27d84b",
              ],
              [
                "a0b1cae06b0a847a3fea6e671aaf8adfdfe58ca2f768105c8082b2e449fce252",
                "ae434102edde0958ec4b19d917a6a28e6b72da1834aff0e650f049503a296cf2",
              ],
              [
                "4e8ceafb9b3e9a136dc7ff67e840295b499dfb3b2133e4ba113f2e4c0e121e5",
                "cf2174118c8b6d7a4b48f6d534ce5c79422c086a63460502b827ce62a326683c",
              ],
              [
                "d24a44e047e19b6f5afb81c7ca2f69080a5076689a010919f42725c2b789a33b",
                "6fb8d5591b466f8fc63db50f1c0f1c69013f996887b8244d2cdec417afea8fa3",
              ],
              [
                "ea01606a7a6c9cdd249fdfcfacb99584001edd28abbab77b5104e98e8e3b35d4",
                "322af4908c7312b0cfbfe369f7a7b3cdb7d4494bc2823700cfd652188a3ea98d",
              ],
              [
                "af8addbf2b661c8a6c6328655eb96651252007d8c5ea31be4ad196de8ce2131f",
                "6749e67c029b85f52a034eafd096836b2520818680e26ac8f3dfbcdb71749700",
              ],
              [
                "e3ae1974566ca06cc516d47e0fb165a674a3dabcfca15e722f0e3450f45889",
                "2aeabe7e4531510116217f07bf4d07300de97e4874f81f533420a72eeb0bd6a4",
              ],
              [
                "591ee355313d99721cf6993ffed1e3e301993ff3ed258802075ea8ced397e246",
                "b0ea558a113c30bea60fc4775460c7901ff0b053d25ca2bdeee98f1a4be5d196",
              ],
              [
                "11396d55fda54c49f19aa97318d8da61fa8584e47b084945077cf03255b52984",
                "998c74a8cd45ac01289d5833a7beb4744ff536b01b257be4c5767bea93ea57a4",
              ],
              [
                "3c5d2a1ba39c5a1790000738c9e0c40b8dcdfd5468754b6405540157e017aa7a",
                "b2284279995a34e2f9d4de7396fc18b80f9b8b9fdd270f6661f79ca4c81bd257",
              ],
              [
                "cc8704b8a60a0defa3a99a7299f2e9c3fbc395afb04ac078425ef8a1793cc030",
                "bdd46039feed17881d1e0862db347f8cf395b74fc4bcdc4e940b74e3ac1f1b13",
              ],
              [
                "c533e4f7ea8555aacd9777ac5cad29b97dd4defccc53ee7ea204119b2889b197",
                "6f0a256bc5efdf429a2fb6242f1a43a2d9b925bb4a4b3a26bb8e0f45eb596096",
              ],
              [
                "c14f8f2ccb27d6f109f6d08d03cc96a69ba8c34eec07bbcf566d48e33da6593",
                "c359d6923bb398f7fd4473e16fe1c28475b740dd098075e6c0e8649113dc3a38",
              ],
              [
                "a6cbc3046bc6a450bac24789fa17115a4c9739ed75f8f21ce441f72e0b90e6ef",
                "21ae7f4680e889bb130619e2c0f95a360ceb573c70603139862afd617fa9b9f",
              ],
              [
                "347d6d9a02c48927ebfb86c1359b1caf130a3c0267d11ce6344b39f99d43cc38",
                "60ea7f61a353524d1c987f6ecec92f086d565ab687870cb12689ff1e31c74448",
              ],
              [
                "da6545d2181db8d983f7dcb375ef5866d47c67b1bf31c8cf855ef7437b72656a",
                "49b96715ab6878a79e78f07ce5680c5d6673051b4935bd897fea824b77dc208a",
              ],
              [
                "c40747cc9d012cb1a13b8148309c6de7ec25d6945d657146b9d5994b8feb1111",
                "5ca560753be2a12fc6de6caf2cb489565db936156b9514e1bb5e83037e0fa2d4",
              ],
              [
                "4e42c8ec82c99798ccf3a610be870e78338c7f713348bd34c8203ef4037f3502",
                "7571d74ee5e0fb92a7a8b33a07783341a5492144cc54bcc40a94473693606437",
              ],
              [
                "3775ab7089bc6af823aba2e1af70b236d251cadb0c86743287522a1b3b0dedea",
                "be52d107bcfa09d8bcb9736a828cfa7fac8db17bf7a76a2c42ad961409018cf7",
              ],
              [
                "cee31cbf7e34ec379d94fb814d3d775ad954595d1314ba8846959e3e82f74e26",
                "8fd64a14c06b589c26b947ae2bcf6bfa0149ef0be14ed4d80f448a01c43b1c6d",
              ],
              [
                "b4f9eaea09b6917619f6ea6a4eb5464efddb58fd45b1ebefcdc1a01d08b47986",
                "39e5c9925b5a54b07433a4f18c61726f8bb131c012ca542eb24a8ac07200682a",
              ],
              [
                "d4263dfc3d2df923a0179a48966d30ce84e2515afc3dccc1b77907792ebcc60e",
                "62dfaf07a0f78feb30e30d6295853ce189e127760ad6cf7fae164e122a208d54",
              ],
              [
                "48457524820fa65a4f8d35eb6930857c0032acc0a4a2de422233eeda897612c4",
                "25a748ab367979d98733c38a1fa1c2e7dc6cc07db2d60a9ae7a76aaa49bd0f77",
              ],
              [
                "dfeeef1881101f2cb11644f3a2afdfc2045e19919152923f367a1767c11cceda",
                "ecfb7056cf1de042f9420bab396793c0c390bde74b4bbdff16a83ae09a9a7517",
              ],
              [
                "6d7ef6b17543f8373c573f44e1f389835d89bcbc6062ced36c82df83b8fae859",
                "cd450ec335438986dfefa10c57fea9bcc521a0959b2d80bbf74b190dca712d10",
              ],
              [
                "e75605d59102a5a2684500d3b991f2e3f3c88b93225547035af25af66e04541f",
                "f5c54754a8f71ee540b9b48728473e314f729ac5308b06938360990e2bfad125",
              ],
              [
                "eb98660f4c4dfaa06a2be453d5020bc99a0c2e60abe388457dd43fefb1ed620c",
                "6cb9a8876d9cb8520609af3add26cd20a0a7cd8a9411131ce85f44100099223e",
              ],
              [
                "13e87b027d8514d35939f2e6892b19922154596941888336dc3563e3b8dba942",
                "fef5a3c68059a6dec5d624114bf1e91aac2b9da568d6abeb2570d55646b8adf1",
              ],
              [
                "ee163026e9fd6fe017c38f06a5be6fc125424b371ce2708e7bf4491691e5764a",
                "1acb250f255dd61c43d94ccc670d0f58f49ae3fa15b96623e5430da0ad6c62b2",
              ],
              [
                "b268f5ef9ad51e4d78de3a750c2dc89b1e626d43505867999932e5db33af3d80",
                "5f310d4b3c99b9ebb19f77d41c1dee018cf0d34fd4191614003e945a1216e423",
              ],
              [
                "ff07f3118a9df035e9fad85eb6c7bfe42b02f01ca99ceea3bf7ffdba93c4750d",
                "438136d603e858a3a5c440c38eccbaddc1d2942114e2eddd4740d098ced1f0d8",
              ],
              [
                "8d8b9855c7c052a34146fd20ffb658bea4b9f69e0d825ebec16e8c3ce2b526a1",
                "cdb559eedc2d79f926baf44fb84ea4d44bcf50fee51d7ceb30e2e7f463036758",
              ],
              [
                "52db0b5384dfbf05bfa9d472d7ae26dfe4b851ceca91b1eba54263180da32b63",
                "c3b997d050ee5d423ebaf66a6db9f57b3180c902875679de924b69d84a7b375",
              ],
              [
                "e62f9490d3d51da6395efd24e80919cc7d0f29c3f3fa48c6fff543becbd43352",
                "6d89ad7ba4876b0b22c2ca280c682862f342c8591f1daf5170e07bfd9ccafa7d",
              ],
              [
                "7f30ea2476b399b4957509c88f77d0191afa2ff5cb7b14fd6d8e7d65aaab1193",
                "ca5ef7d4b231c94c3b15389a5f6311e9daff7bb67b103e9880ef4bff637acaec",
              ],
              [
                "5098ff1e1d9f14fb46a210fada6c903fef0fb7b4a1dd1d9ac60a0361800b7a00",
                "9731141d81fc8f8084d37c6e7542006b3ee1b40d60dfe5362a5b132fd17ddc0",
              ],
              [
                "32b78c7de9ee512a72895be6b9cbefa6e2f3c4ccce445c96b9f2c81e2778ad58",
                "ee1849f513df71e32efc3896ee28260c73bb80547ae2275ba497237794c8753c",
              ],
              [
                "e2cb74fddc8e9fbcd076eef2a7c72b0ce37d50f08269dfc074b581550547a4f7",
                "d3aa2ed71c9dd2247a62df062736eb0baddea9e36122d2be8641abcb005cc4a4",
              ],
              [
                "8438447566d4d7bedadc299496ab357426009a35f235cb141be0d99cd10ae3a8",
                "c4e1020916980a4da5d01ac5e6ad330734ef0d7906631c4f2390426b2edd791f",
              ],
              [
                "4162d488b89402039b584c6fc6c308870587d9c46f660b878ab65c82c711d67e",
                "67163e903236289f776f22c25fb8a3afc1732f2b84b4e95dbda47ae5a0852649",
              ],
              [
                "3fad3fa84caf0f34f0f89bfd2dcf54fc175d767aec3e50684f3ba4a4bf5f683d",
                "cd1bc7cb6cc407bb2f0ca647c718a730cf71872e7d0d2a53fa20efcdfe61826",
              ],
              [
                "674f2600a3007a00568c1a7ce05d0816c1fb84bf1370798f1c69532faeb1a86b",
                "299d21f9413f33b3edf43b257004580b70db57da0b182259e09eecc69e0d38a5",
              ],
              [
                "d32f4da54ade74abb81b815ad1fb3b263d82d6c692714bcff87d29bd5ee9f08f",
                "f9429e738b8e53b968e99016c059707782e14f4535359d582fc416910b3eea87",
              ],
              [
                "30e4e670435385556e593657135845d36fbb6931f72b08cb1ed954f1e3ce3ff6",
                "462f9bce619898638499350113bbc9b10a878d35da70740dc695a559eb88db7b",
              ],
              [
                "be2062003c51cc3004682904330e4dee7f3dcd10b01e580bf1971b04d4cad297",
                "62188bc49d61e5428573d48a74e1c655b1c61090905682a0d5558ed72dccb9bc",
              ],
              [
                "93144423ace3451ed29e0fb9ac2af211cb6e84a601df5993c419859fff5df04a",
                "7c10dfb164c3425f5c71a3f9d7992038f1065224f72bb9d1d902a6d13037b47c",
              ],
              [
                "b015f8044f5fcbdcf21ca26d6c34fb8197829205c7b7d2a7cb66418c157b112c",
                "ab8c1e086d04e813744a655b2df8d5f83b3cdc6faa3088c1d3aea1454e3a1d5f",
              ],
              [
                "d5e9e1da649d97d89e4868117a465a3a4f8a18de57a140d36b3f2af341a21b52",
                "4cb04437f391ed73111a13cc1d4dd0db1693465c2240480d8955e8592f27447a",
              ],
              [
                "d3ae41047dd7ca065dbf8ed77b992439983005cd72e16d6f996a5316d36966bb",
                "bd1aeb21ad22ebb22a10f0303417c6d964f8cdd7df0aca614b10dc14d125ac46",
              ],
              [
                "463e2763d885f958fc66cdd22800f0a487197d0a82e377b49f80af87c897b065",
                "bfefacdb0e5d0fd7df3a311a94de062b26b80c61fbc97508b79992671ef7ca7f",
              ],
              [
                "7985fdfd127c0567c6f53ec1bb63ec3158e597c40bfe747c83cddfc910641917",
                "603c12daf3d9862ef2b25fe1de289aed24ed291e0ec6708703a5bd567f32ed03",
              ],
              [
                "74a1ad6b5f76e39db2dd249410eac7f99e74c59cb83d2d0ed5ff1543da7703e9",
                "cc6157ef18c9c63cd6193d83631bbea0093e0968942e8c33d5737fd790e0db08",
              ],
              [
                "30682a50703375f602d416664ba19b7fc9bab42c72747463a71d0896b22f6da3",
                "553e04f6b018b4fa6c8f39e7f311d3176290d0e0f19ca73f17714d9977a22ff8",
              ],
              [
                "9e2158f0d7c0d5f26c3791efefa79597654e7a2b2464f52b1ee6c1347769ef57",
                "712fcdd1b9053f09003a3481fa7762e9ffd7c8ef35a38509e2fbf2629008373",
              ],
              [
                "176e26989a43c9cfeba4029c202538c28172e566e3c4fce7322857f3be327d66",
                "ed8cc9d04b29eb877d270b4878dc43c19aefd31f4eee09ee7b47834c1fa4b1c3",
              ],
              [
                "75d46efea3771e6e68abb89a13ad747ecf1892393dfc4f1b7004788c50374da8",
                "9852390a99507679fd0b86fd2b39a868d7efc22151346e1a3ca4726586a6bed8",
              ],
              [
                "809a20c67d64900ffb698c4c825f6d5f2310fb0451c869345b7319f645605721",
                "9e994980d9917e22b76b061927fa04143d096ccc54963e6a5ebfa5f3f8e286c1",
              ],
              [
                "1b38903a43f7f114ed4500b4eac7083fdefece1cf29c63528d563446f972c180",
                "4036edc931a60ae889353f77fd53de4a2708b26b6f5da72ad3394119daf408f9",
              ],
            ],
          },
        };
      },
      {},
    ],
    42: [
      function (require, module, exports) {
        "use strict";
        var utils = exports;
        var BN = require("bn.js");
        var minAssert = require("minimalistic-assert");
        var minUtils = require("minimalistic-crypto-utils");
        utils.assert = minAssert;
        utils.toArray = minUtils.toArray;
        utils.zero2 = minUtils.zero2;
        utils.toHex = minUtils.toHex;
        utils.encode = minUtils.encode;
        function getNAF(num, w, bits) {
          var naf = new Array(Math.max(num.bitLength(), bits) + 1);
          naf.fill(0);
          var ws = 1 << (w + 1);
          var k = num.clone();
          for (var i = 0; i < naf.length; i++) {
            var z;
            var mod = k.andln(ws - 1);
            if (k.isOdd()) {
              if (mod > (ws >> 1) - 1) z = (ws >> 1) - mod;
              else z = mod;
              k.isubn(z);
            } else {
              z = 0;
            }
            naf[i] = z;
            k.iushrn(1);
          }
          return naf;
        }
        utils.getNAF = getNAF;
        function getJSF(k1, k2) {
          var jsf = [[], []];
          k1 = k1.clone();
          k2 = k2.clone();
          var d1 = 0;
          var d2 = 0;
          var m8;
          while (k1.cmpn(-d1) > 0 || k2.cmpn(-d2) > 0) {
            var m14 = (k1.andln(3) + d1) & 3;
            var m24 = (k2.andln(3) + d2) & 3;
            if (m14 === 3) m14 = -1;
            if (m24 === 3) m24 = -1;
            var u1;
            if ((m14 & 1) === 0) {
              u1 = 0;
            } else {
              m8 = (k1.andln(7) + d1) & 7;
              if ((m8 === 3 || m8 === 5) && m24 === 2) u1 = -m14;
              else u1 = m14;
            }
            jsf[0].push(u1);
            var u2;
            if ((m24 & 1) === 0) {
              u2 = 0;
            } else {
              m8 = (k2.andln(7) + d2) & 7;
              if ((m8 === 3 || m8 === 5) && m14 === 2) u2 = -m24;
              else u2 = m24;
            }
            jsf[1].push(u2);
            if (2 * d1 === u1 + 1) d1 = 1 - d1;
            if (2 * d2 === u2 + 1) d2 = 1 - d2;
            k1.iushrn(1);
            k2.iushrn(1);
          }
          return jsf;
        }
        utils.getJSF = getJSF;
        function cachedProperty(obj, name, computer) {
          var key = "_" + name;
          obj.prototype[name] = function cachedProperty() {
            return this[key] !== undefined
              ? this[key]
              : (this[key] = computer.call(this));
          };
        }
        utils.cachedProperty = cachedProperty;
        function parseBytes(bytes) {
          return typeof bytes === "string"
            ? utils.toArray(bytes, "hex")
            : bytes;
        }
        utils.parseBytes = parseBytes;
        function intFromLE(bytes) {
          return new BN(bytes, "hex", "le");
        }
        utils.intFromLE = intFromLE;
      },
      {
        "bn.js": 43,
        "minimalistic-assert": 119,
        "minimalistic-crypto-utils": 120,
      },
    ],
    43: [
      function (require, module, exports) {
        arguments[4][6][0].apply(exports, arguments);
      },
      { buffer: 24, dup: 6 },
    ],
    44: [
      function (require, module, exports) {
        module.exports = {
          name: "elliptic",
          version: "6.5.4",
          description: "EC cryptography",
          main: "lib/elliptic.js",
          files: ["lib"],
          scripts: {
            lint: "eslint lib test",
            "lint:fix": "npm run lint -- --fix",
            unit: "istanbul test _mocha --reporter=spec test/index.js",
            test: "npm run lint && npm run unit",
            version: "grunt dist && git add dist/",
          },
          repository: { type: "git", url: "git@github.com:indutny/elliptic" },
          keywords: ["EC", "Elliptic", "curve", "Cryptography"],
          author: "Fedor Indutny <fedor@indutny.com>",
          license: "MIT",
          bugs: { url: "https://github.com/indutny/elliptic/issues" },
          homepage: "https://github.com/indutny/elliptic",
          devDependencies: {
            brfs: "^2.0.2",
            coveralls: "^3.1.0",
            eslint: "^7.6.0",
            grunt: "^1.2.1",
            "grunt-browserify": "^5.3.0",
            "grunt-cli": "^1.3.2",
            "grunt-contrib-connect": "^3.0.0",
            "grunt-contrib-copy": "^1.0.0",
            "grunt-contrib-uglify": "^5.0.0",
            "grunt-mocha-istanbul": "^5.0.2",
            "grunt-saucelabs": "^9.0.1",
            istanbul: "^0.4.5",
            mocha: "^8.0.1",
          },
          dependencies: {
            "bn.js": "^4.11.9",
            brorand: "^1.1.0",
            "hash.js": "^1.0.0",
            "hmac-drbg": "^1.0.1",
            inherits: "^2.0.4",
            "minimalistic-assert": "^1.0.1",
            "minimalistic-crypto-utils": "^1.0.1",
          },
        };
      },
      {},
    ],
    45: [
      function (require, module, exports) {
        (function (Buffer) {
          (function () {
            "use strict";
            Object.defineProperty(exports, "__esModule", { value: true });
            function createHashFunction(hashConstructor) {
              return function (msg) {
                var hash = hashConstructor();
                hash.update(msg);
                return Buffer.from(hash.digest());
              };
            }
            exports.createHashFunction = createHashFunction;
          }).call(this);
        }).call(this, require("buffer").Buffer);
      },
      { buffer: 25 },
    ],
    46: [
      function (require, module, exports) {
        "use strict";
        Object.defineProperty(exports, "__esModule", { value: true });
        var hash_utils_1 = require("./hash-utils");
        var createKeccakHash = require("keccak");
        exports.keccak224 = hash_utils_1.createHashFunction(function () {
          return createKeccakHash("keccak224");
        });
        exports.keccak256 = hash_utils_1.createHashFunction(function () {
          return createKeccakHash("keccak256");
        });
        exports.keccak384 = hash_utils_1.createHashFunction(function () {
          return createKeccakHash("keccak384");
        });
        exports.keccak512 = hash_utils_1.createHashFunction(function () {
          return createKeccakHash("keccak512");
        });
      },
      { "./hash-utils": 45, keccak: 97 },
    ],
    47: [
      function (require, module, exports) {
        "use strict";
        Object.defineProperty(exports, "__esModule", { value: true });
        var randombytes = require("randombytes");
        function getRandomBytes(bytes) {
          return new Promise(function (resolve, reject) {
            randombytes(bytes, function (err, resp) {
              if (err) {
                reject(err);
                return;
              }
              resolve(resp);
            });
          });
        }
        exports.getRandomBytes = getRandomBytes;
        function getRandomBytesSync(bytes) {
          return randombytes(bytes);
        }
        exports.getRandomBytesSync = getRandomBytesSync;
      },
      { randombytes: 123 },
    ],
    48: [
      function (require, module, exports) {
        "use strict";
        var __awaiter =
          (this && this.__awaiter) ||
          function (thisArg, _arguments, P, generator) {
            function adopt(value) {
              return value instanceof P
                ? value
                : new P(function (resolve) {
                    resolve(value);
                  });
            }
            return new (P || (P = Promise))(function (resolve, reject) {
              function fulfilled(value) {
                try {
                  step(generator.next(value));
                } catch (e) {
                  reject(e);
                }
              }
              function rejected(value) {
                try {
                  step(generator["throw"](value));
                } catch (e) {
                  reject(e);
                }
              }
              function step(result) {
                result.done
                  ? resolve(result.value)
                  : adopt(result.value).then(fulfilled, rejected);
              }
              step(
                (generator = generator.apply(thisArg, _arguments || [])).next()
              );
            });
          };
        var __generator =
          (this && this.__generator) ||
          function (thisArg, body) {
            var _ = {
                label: 0,
                sent: function () {
                  if (t[0] & 1) throw t[1];
                  return t[1];
                },
                trys: [],
                ops: [],
              },
              f,
              y,
              t,
              g;
            return (
              (g = { next: verb(0), throw: verb(1), return: verb(2) }),
              typeof Symbol === "function" &&
                (g[Symbol.iterator] = function () {
                  return this;
                }),
              g
            );
            function verb(n) {
              return function (v) {
                return step([n, v]);
              };
            }
            function step(op) {
              if (f) throw new TypeError("Generator is already executing.");
              while (_)
                try {
                  if (
                    ((f = 1),
                    y &&
                      (t =
                        op[0] & 2
                          ? y["return"]
                          : op[0]
                          ? y["throw"] || ((t = y["return"]) && t.call(y), 0)
                          : y.next) &&
                      !(t = t.call(y, op[1])).done)
                  )
                    return t;
                  if (((y = 0), t)) op = [op[0] & 2, t.value];
                  switch (op[0]) {
                    case 0:
                    case 1:
                      t = op;
                      break;
                    case 4:
                      _.label++;
                      return { value: op[1], done: false };
                    case 5:
                      _.label++;
                      y = op[1];
                      op = [0];
                      continue;
                    case 7:
                      op = _.ops.pop();
                      _.trys.pop();
                      continue;
                    default:
                      if (
                        !((t = _.trys),
                        (t = t.length > 0 && t[t.length - 1])) &&
                        (op[0] === 6 || op[0] === 2)
                      ) {
                        _ = 0;
                        continue;
                      }
                      if (
                        op[0] === 3 &&
                        (!t || (op[1] > t[0] && op[1] < t[3]))
                      ) {
                        _.label = op[1];
                        break;
                      }
                      if (op[0] === 6 && _.label < t[1]) {
                        _.label = t[1];
                        t = op;
                        break;
                      }
                      if (t && _.label < t[2]) {
                        _.label = t[2];
                        _.ops.push(op);
                        break;
                      }
                      if (t[2]) _.ops.pop();
                      _.trys.pop();
                      continue;
                  }
                  op = body.call(thisArg, _);
                } catch (e) {
                  op = [6, e];
                  y = 0;
                } finally {
                  f = t = 0;
                }
              if (op[0] & 5) throw op[1];
              return { value: op[0] ? op[1] : void 0, done: true };
            }
          };
        function __export(m) {
          for (var p in m) if (!exports.hasOwnProperty(p)) exports[p] = m[p];
        }
        Object.defineProperty(exports, "__esModule", { value: true });
        var secp256k1_1 = require("secp256k1");
        var random_1 = require("./random");
        var SECP256K1_PRIVATE_KEY_SIZE = 32;
        function createPrivateKey() {
          return __awaiter(this, void 0, void 0, function () {
            var pk;
            return __generator(this, function (_a) {
              switch (_a.label) {
                case 0:
                  if (!true) return [3, 2];
                  return [
                    4,
                    random_1.getRandomBytes(SECP256K1_PRIVATE_KEY_SIZE),
                  ];
                case 1:
                  pk = _a.sent();
                  if (secp256k1_1.privateKeyVerify(pk)) {
                    return [2, pk];
                  }
                  return [3, 0];
                case 2:
                  return [2];
              }
            });
          });
        }
        exports.createPrivateKey = createPrivateKey;
        function createPrivateKeySync() {
          while (true) {
            var pk = random_1.getRandomBytesSync(SECP256K1_PRIVATE_KEY_SIZE);
            if (secp256k1_1.privateKeyVerify(pk)) {
              return pk;
            }
          }
        }
        exports.createPrivateKeySync = createPrivateKeySync;
        __export(require("secp256k1"));
      },
      { "./random": 47, secp256k1: 127 },
    ],
    49: [
      function (require, module, exports) {
        module.exports = require("./lib/index.js");
      },
      { "./lib/index.js": 50 },
    ],
    50: [
      function (require, module, exports) {
        (function (Buffer) {
          (function () {
            const utils = require("ethereumjs-util");
            const BN = require("bn.js");
            var ABI = function () {};
            function elementaryName(name) {
              if (name.startsWith("int[")) {
                return "int256" + name.slice(3);
              } else if (name === "int") {
                return "int256";
              } else if (name.startsWith("uint[")) {
                return "uint256" + name.slice(4);
              } else if (name === "uint") {
                return "uint256";
              } else if (name.startsWith("fixed[")) {
                return "fixed128x128" + name.slice(5);
              } else if (name === "fixed") {
                return "fixed128x128";
              } else if (name.startsWith("ufixed[")) {
                return "ufixed128x128" + name.slice(6);
              } else if (name === "ufixed") {
                return "ufixed128x128";
              }
              return name;
            }
            ABI.eventID = function (name, types) {
              var sig = name + "(" + types.map(elementaryName).join(",") + ")";
              return utils.keccak256(Buffer.from(sig));
            };
            ABI.methodID = function (name, types) {
              return ABI.eventID(name, types).slice(0, 4);
            };
            function parseTypeN(type) {
              return parseInt(/^\D+(\d+)$/.exec(type)[1], 10);
            }
            function parseTypeNxM(type) {
              var tmp = /^\D+(\d+)x(\d+)$/.exec(type);
              return [parseInt(tmp[1], 10), parseInt(tmp[2], 10)];
            }
            function parseTypeArray(type) {
              var tmp = type.match(/(.*)\[(.*?)\]$/);
              if (tmp) {
                return tmp[2] === "" ? "dynamic" : parseInt(tmp[2], 10);
              }
              return null;
            }
            function parseNumber(arg) {
              var type = typeof arg;
              if (type === "string") {
                if (utils.isHexPrefixed(arg)) {
                  return new BN(utils.stripHexPrefix(arg), 16);
                } else {
                  return new BN(arg, 10);
                }
              } else if (type === "number") {
                return new BN(arg);
              } else if (arg.toArray) {
                return arg;
              } else {
                throw new Error("Argument is not a number");
              }
            }
            function parseSignature(sig) {
              var tmp = /^(\w+)\((.*)\)$/.exec(sig);
              if (tmp.length !== 3) {
                throw new Error("Invalid method signature");
              }
              var args = /^(.+)\):\((.+)$/.exec(tmp[2]);
              if (args !== null && args.length === 3) {
                return {
                  method: tmp[1],
                  args: args[1].split(","),
                  retargs: args[2].split(","),
                };
              } else {
                var params = tmp[2].split(",");
                if (params.length === 1 && params[0] === "") {
                  params = [];
                }
                return { method: tmp[1], args: params };
              }
            }
            function encodeSingle(type, arg) {
              var size, num, ret, i;
              if (type === "address") {
                return encodeSingle("uint160", parseNumber(arg));
              } else if (type === "bool") {
                return encodeSingle("uint8", arg ? 1 : 0);
              } else if (type === "string") {
                return encodeSingle("bytes", Buffer.from(arg, "utf8"));
              } else if (isArray(type)) {
                if (typeof arg.length === "undefined") {
                  throw new Error("Not an array?");
                }
                size = parseTypeArray(type);
                if (size !== "dynamic" && size !== 0 && arg.length > size) {
                  throw new Error("Elements exceed array size: " + size);
                }
                ret = [];
                type = type.slice(0, type.lastIndexOf("["));
                if (typeof arg === "string") {
                  arg = JSON.parse(arg);
                }
                for (i in arg) {
                  ret.push(encodeSingle(type, arg[i]));
                }
                if (size === "dynamic") {
                  var length = encodeSingle("uint256", arg.length);
                  ret.unshift(length);
                }
                return Buffer.concat(ret);
              } else if (type === "bytes") {
                arg = Buffer.from(arg);
                ret = Buffer.concat([encodeSingle("uint256", arg.length), arg]);
                if (arg.length % 32 !== 0) {
                  ret = Buffer.concat([
                    ret,
                    utils.zeros(32 - (arg.length % 32)),
                  ]);
                }
                return ret;
              } else if (type.startsWith("bytes")) {
                size = parseTypeN(type);
                if (size < 1 || size > 32) {
                  throw new Error("Invalid bytes<N> width: " + size);
                }
                return utils.setLengthRight(arg, 32);
              } else if (type.startsWith("uint")) {
                size = parseTypeN(type);
                if (size % 8 || size < 8 || size > 256) {
                  throw new Error("Invalid uint<N> width: " + size);
                }
                num = parseNumber(arg);
                if (num.bitLength() > size) {
                  throw new Error(
                    "Supplied uint exceeds width: " +
                      size +
                      " vs " +
                      num.bitLength()
                  );
                }
                if (num < 0) {
                  throw new Error("Supplied uint is negative");
                }
                return num.toArrayLike(Buffer, "be", 32);
              } else if (type.startsWith("int")) {
                size = parseTypeN(type);
                if (size % 8 || size < 8 || size > 256) {
                  throw new Error("Invalid int<N> width: " + size);
                }
                num = parseNumber(arg);
                if (num.bitLength() > size) {
                  throw new Error(
                    "Supplied int exceeds width: " +
                      size +
                      " vs " +
                      num.bitLength()
                  );
                }
                return num.toTwos(256).toArrayLike(Buffer, "be", 32);
              } else if (type.startsWith("ufixed")) {
                size = parseTypeNxM(type);
                num = parseNumber(arg);
                if (num < 0) {
                  throw new Error("Supplied ufixed is negative");
                }
                return encodeSingle(
                  "uint256",
                  num.mul(new BN(2).pow(new BN(size[1])))
                );
              } else if (type.startsWith("fixed")) {
                size = parseTypeNxM(type);
                return encodeSingle(
                  "int256",
                  parseNumber(arg).mul(new BN(2).pow(new BN(size[1])))
                );
              }
              throw new Error("Unsupported or invalid type: " + type);
            }
            function decodeSingle(parsedType, data, offset) {
              if (typeof parsedType === "string") {
                parsedType = parseType(parsedType);
              }
              var size, num, ret, i;
              if (parsedType.name === "address") {
                return decodeSingle(parsedType.rawType, data, offset)
                  .toArrayLike(Buffer, "be", 20)
                  .toString("hex");
              } else if (parsedType.name === "bool") {
                return (
                  decodeSingle(parsedType.rawType, data, offset).toString() ===
                  new BN(1).toString()
                );
              } else if (parsedType.name === "string") {
                var bytes = decodeSingle(parsedType.rawType, data, offset);
                return Buffer.from(bytes, "utf8").toString();
              } else if (parsedType.isArray) {
                ret = [];
                size = parsedType.size;
                if (parsedType.size === "dynamic") {
                  offset = decodeSingle("uint256", data, offset).toNumber();
                  size = decodeSingle("uint256", data, offset).toNumber();
                  offset = offset + 32;
                }
                for (i = 0; i < size; i++) {
                  var decoded = decodeSingle(parsedType.subArray, data, offset);
                  ret.push(decoded);
                  offset += parsedType.subArray.memoryUsage;
                }
                return ret;
              } else if (parsedType.name === "bytes") {
                offset = decodeSingle("uint256", data, offset).toNumber();
                size = decodeSingle("uint256", data, offset).toNumber();
                return data.slice(offset + 32, offset + 32 + size);
              } else if (parsedType.name.startsWith("bytes")) {
                return data.slice(offset, offset + parsedType.size);
              } else if (parsedType.name.startsWith("uint")) {
                num = new BN(data.slice(offset, offset + 32), 16, "be");
                if (num.bitLength() > parsedType.size) {
                  throw new Error(
                    "Decoded int exceeds width: " +
                      parsedType.size +
                      " vs " +
                      num.bitLength()
                  );
                }
                return num;
              } else if (parsedType.name.startsWith("int")) {
                num = new BN(
                  data.slice(offset, offset + 32),
                  16,
                  "be"
                ).fromTwos(256);
                if (num.bitLength() > parsedType.size) {
                  throw new Error(
                    "Decoded uint exceeds width: " +
                      parsedType.size +
                      " vs " +
                      num.bitLength()
                  );
                }
                return num;
              } else if (parsedType.name.startsWith("ufixed")) {
                size = new BN(2).pow(new BN(parsedType.size[1]));
                num = decodeSingle("uint256", data, offset);
                if (!num.mod(size).isZero()) {
                  throw new Error("Decimals not supported yet");
                }
                return num.div(size);
              } else if (parsedType.name.startsWith("fixed")) {
                size = new BN(2).pow(new BN(parsedType.size[1]));
                num = decodeSingle("int256", data, offset);
                if (!num.mod(size).isZero()) {
                  throw new Error("Decimals not supported yet");
                }
                return num.div(size);
              }
              throw new Error(
                "Unsupported or invalid type: " + parsedType.name
              );
            }
            function parseType(type) {
              var size;
              var ret;
              if (isArray(type)) {
                size = parseTypeArray(type);
                var subArray = type.slice(0, type.lastIndexOf("["));
                subArray = parseType(subArray);
                ret = {
                  isArray: true,
                  name: type,
                  size: size,
                  memoryUsage:
                    size === "dynamic" ? 32 : subArray.memoryUsage * size,
                  subArray: subArray,
                };
                return ret;
              } else {
                var rawType;
                switch (type) {
                  case "address":
                    rawType = "uint160";
                    break;
                  case "bool":
                    rawType = "uint8";
                    break;
                  case "string":
                    rawType = "bytes";
                    break;
                }
                ret = { rawType: rawType, name: type, memoryUsage: 32 };
                if (
                  (type.startsWith("bytes") && type !== "bytes") ||
                  type.startsWith("uint") ||
                  type.startsWith("int")
                ) {
                  ret.size = parseTypeN(type);
                } else if (
                  type.startsWith("ufixed") ||
                  type.startsWith("fixed")
                ) {
                  ret.size = parseTypeNxM(type);
                }
                if (
                  type.startsWith("bytes") &&
                  type !== "bytes" &&
                  (ret.size < 1 || ret.size > 32)
                ) {
                  throw new Error("Invalid bytes<N> width: " + ret.size);
                }
                if (
                  (type.startsWith("uint") || type.startsWith("int")) &&
                  (ret.size % 8 || ret.size < 8 || ret.size > 256)
                ) {
                  throw new Error("Invalid int/uint<N> width: " + ret.size);
                }
                return ret;
              }
            }
            function isDynamic(type) {
              return (
                type === "string" ||
                type === "bytes" ||
                parseTypeArray(type) === "dynamic"
              );
            }
            function isArray(type) {
              return type.lastIndexOf("]") === type.length - 1;
            }
            ABI.rawEncode = function (types, values) {
              var output = [];
              var data = [];
              var headLength = 0;
              types.forEach(function (type) {
                if (isArray(type)) {
                  var size = parseTypeArray(type);
                  if (size !== "dynamic") {
                    headLength += 32 * size;
                  } else {
                    headLength += 32;
                  }
                } else {
                  headLength += 32;
                }
              });
              for (var i = 0; i < types.length; i++) {
                var type = elementaryName(types[i]);
                var value = values[i];
                var cur = encodeSingle(type, value);
                if (isDynamic(type)) {
                  output.push(encodeSingle("uint256", headLength));
                  data.push(cur);
                  headLength += cur.length;
                } else {
                  output.push(cur);
                }
              }
              return Buffer.concat(output.concat(data));
            };
            ABI.rawDecode = function (types, data) {
              var ret = [];
              data = Buffer.from(data);
              var offset = 0;
              for (var i = 0; i < types.length; i++) {
                var type = elementaryName(types[i]);
                var parsed = parseType(type, data, offset);
                var decoded = decodeSingle(parsed, data, offset);
                offset += parsed.memoryUsage;
                ret.push(decoded);
              }
              return ret;
            };
            ABI.simpleEncode = function (method) {
              var args = Array.prototype.slice.call(arguments).slice(1);
              var sig = parseSignature(method);
              if (args.length !== sig.args.length) {
                throw new Error("Argument count mismatch");
              }
              return Buffer.concat([
                ABI.methodID(sig.method, sig.args),
                ABI.rawEncode(sig.args, args),
              ]);
            };
            ABI.simpleDecode = function (method, data) {
              var sig = parseSignature(method);
              if (!sig.retargs) {
                throw new Error("No return values in method");
              }
              return ABI.rawDecode(sig.retargs, data);
            };
            function stringify(type, value) {
              if (type.startsWith("address") || type.startsWith("bytes")) {
                return "0x" + value.toString("hex");
              } else {
                return value.toString();
              }
            }
            ABI.stringify = function (types, values) {
              var ret = [];
              for (var i in types) {
                var type = types[i];
                var value = values[i];
                if (/^[^\[]+\[.*\]$/.test(type)) {
                  value = value
                    .map(function (item) {
                      return stringify(type, item);
                    })
                    .join(", ");
                } else {
                  value = stringify(type, value);
                }
                ret.push(value);
              }
              return ret;
            };
            ABI.solidityHexValue = function (type, value, bitsize) {
              var size, num;
              if (isArray(type)) {
                var subType = type.replace(/\[.*?\]/, "");
                if (!isArray(subType)) {
                  var arraySize = parseTypeArray(type);
                  if (
                    arraySize !== "dynamic" &&
                    arraySize !== 0 &&
                    value.length > arraySize
                  ) {
                    throw new Error("Elements exceed array size: " + arraySize);
                  }
                }
                var arrayValues = value.map(function (v) {
                  return ABI.solidityHexValue(subType, v, 256);
                });
                return Buffer.concat(arrayValues);
              } else if (type === "bytes") {
                return value;
              } else if (type === "string") {
                return Buffer.from(value, "utf8");
              } else if (type === "bool") {
                bitsize = bitsize || 8;
                var padding = Array(bitsize / 4).join("0");
                return Buffer.from(
                  value ? padding + "1" : padding + "0",
                  "hex"
                );
              } else if (type === "address") {
                var bytesize = 20;
                if (bitsize) {
                  bytesize = bitsize / 8;
                }
                return utils.setLengthLeft(value, bytesize);
              } else if (type.startsWith("bytes")) {
                size = parseTypeN(type);
                if (size < 1 || size > 32) {
                  throw new Error("Invalid bytes<N> width: " + size);
                }
                return utils.setLengthRight(value, size);
              } else if (type.startsWith("uint")) {
                size = parseTypeN(type);
                if (size % 8 || size < 8 || size > 256) {
                  throw new Error("Invalid uint<N> width: " + size);
                }
                num = parseNumber(value);
                if (num.bitLength() > size) {
                  throw new Error(
                    "Supplied uint exceeds width: " +
                      size +
                      " vs " +
                      num.bitLength()
                  );
                }
                bitsize = bitsize || size;
                return num.toArrayLike(Buffer, "be", bitsize / 8);
              } else if (type.startsWith("int")) {
                size = parseTypeN(type);
                if (size % 8 || size < 8 || size > 256) {
                  throw new Error("Invalid int<N> width: " + size);
                }
                num = parseNumber(value);
                if (num.bitLength() > size) {
                  throw new Error(
                    "Supplied int exceeds width: " +
                      size +
                      " vs " +
                      num.bitLength()
                  );
                }
                bitsize = bitsize || size;
                return num.toTwos(size).toArrayLike(Buffer, "be", bitsize / 8);
              } else {
                throw new Error("Unsupported or invalid type: " + type);
              }
            };
            ABI.solidityPack = function (types, values) {
              if (types.length !== values.length) {
                throw new Error("Number of types are not matching the values");
              }
              var ret = [];
              for (var i = 0; i < types.length; i++) {
                var type = elementaryName(types[i]);
                var value = values[i];
                ret.push(ABI.solidityHexValue(type, value, null));
              }
              return Buffer.concat(ret);
            };
            ABI.soliditySHA3 = function (types, values) {
              return utils.keccak256(ABI.solidityPack(types, values));
            };
            ABI.soliditySHA256 = function (types, values) {
              return utils.sha256(ABI.solidityPack(types, values));
            };
            ABI.solidityRIPEMD160 = function (types, values) {
              return utils.ripemd160(ABI.solidityPack(types, values), true);
            };
            function isNumeric(c) {
              return c >= "0" && c <= "9";
            }
            ABI.fromSerpent = function (sig) {
              var ret = [];
              for (var i = 0; i < sig.length; i++) {
                var type = sig[i];
                if (type === "s") {
                  ret.push("bytes");
                } else if (type === "b") {
                  var tmp = "bytes";
                  var j = i + 1;
                  while (j < sig.length && isNumeric(sig[j])) {
                    tmp += sig[j] - "0";
                    j++;
                  }
                  i = j - 1;
                  ret.push(tmp);
                } else if (type === "i") {
                  ret.push("int256");
                } else if (type === "a") {
                  ret.push("int256[]");
                } else {
                  throw new Error("Unsupported or invalid type: " + type);
                }
              }
              return ret;
            };
            ABI.toSerpent = function (types) {
              var ret = [];
              for (var i = 0; i < types.length; i++) {
                var type = types[i];
                if (type === "bytes") {
                  ret.push("s");
                } else if (type.startsWith("bytes")) {
                  ret.push("b" + parseTypeN(type));
                } else if (type === "int256") {
                  ret.push("i");
                } else if (type === "int256[]") {
                  ret.push("a");
                } else {
                  throw new Error("Unsupported or invalid type: " + type);
                }
              }
              return ret.join("");
            };
            module.exports = ABI;
          }).call(this);
        }).call(this, require("buffer").Buffer);
      },
      { "bn.js": 51, buffer: 25, "ethereumjs-util": 56 },
    ],
    51: [
      function (require, module, exports) {
        arguments[4][6][0].apply(exports, arguments);
      },
      { buffer: 24, dup: 6 },
    ],
    52: [
      function (require, module, exports) {
        arguments[4][7][0].apply(exports, arguments);
      },
      {
        "./bytes": 53,
        "./hash": 55,
        "./secp256k1v3-adapter": 58,
        assert: 17,
        "bn.js": 51,
        buffer: 25,
        dup: 7,
        "ethjs-util": 62,
      },
    ],
    53: [
      function (require, module, exports) {
        arguments[4][8][0].apply(exports, arguments);
      },
      { "bn.js": 51, buffer: 25, dup: 8, "ethjs-util": 62 },
    ],
    54: [
      function (require, module, exports) {
        arguments[4][9][0].apply(exports, arguments);
      },
      { "bn.js": 51, buffer: 25, dup: 9 },
    ],
    55: [
      function (require, module, exports) {
        arguments[4][10][0].apply(exports, arguments);
      },
      {
        "./bytes": 53,
        buffer: 25,
        "create-hash": 27,
        dup: 10,
        "ethereum-cryptography/keccak": 46,
        "ethjs-util": 62,
        rlp: 125,
      },
    ],
    56: [
      function (require, module, exports) {
        arguments[4][11][0].apply(exports, arguments);
      },
      {
        "./account": 52,
        "./bytes": 53,
        "./constants": 54,
        "./hash": 55,
        "./object": 57,
        "./secp256k1v3-adapter": 58,
        "./signature": 61,
        "bn.js": 51,
        dup: 11,
        "ethjs-util": 62,
        rlp: 125,
      },
    ],
    57: [
      function (require, module, exports) {
        arguments[4][12][0].apply(exports, arguments);
      },
      {
        "./bytes": 53,
        assert: 17,
        buffer: 25,
        dup: 12,
        "ethjs-util": 62,
        rlp: 125,
      },
    ],
    58: [
      function (require, module, exports) {
        arguments[4][13][0].apply(exports, arguments);
      },
      {
        "./secp256k1v3-lib/der": 59,
        "./secp256k1v3-lib/index": 60,
        buffer: 25,
        dup: 13,
        "ethereum-cryptography/secp256k1": 48,
      },
    ],
    59: [
      function (require, module, exports) {
        arguments[4][14][0].apply(exports, arguments);
      },
      { buffer: 25, dup: 14 },
    ],
    60: [
      function (require, module, exports) {
        arguments[4][15][0].apply(exports, arguments);
      },
      { "bn.js": 51, buffer: 25, dup: 15, elliptic: 28 },
    ],
    61: [
      function (require, module, exports) {
        arguments[4][16][0].apply(exports, arguments);
      },
      {
        "./bytes": 53,
        "./hash": 55,
        "./secp256k1v3-adapter": 58,
        "bn.js": 51,
        buffer: 25,
        dup: 16,
      },
    ],
    62: [
      function (require, module, exports) {
        (function (Buffer) {
          (function () {
            "use strict";
            var isHexPrefixed = require("is-hex-prefixed");
            var stripHexPrefix = require("strip-hex-prefix");
            function padToEven(value) {
              var a = value;
              if (typeof a !== "string") {
                throw new Error(
                  "[ethjs-util] while padding to even, value must be string, is currently " +
                    typeof a +
                    ", while padToEven."
                );
              }
              if (a.length % 2) {
                a = "0" + a;
              }
              return a;
            }
            function intToHex(i) {
              var hex = i.toString(16);
              return "0x" + hex;
            }
            function intToBuffer(i) {
              var hex = intToHex(i);
              return new Buffer(padToEven(hex.slice(2)), "hex");
            }
            function getBinarySize(str) {
              if (typeof str !== "string") {
                throw new Error(
                  "[ethjs-util] while getting binary size, method getBinarySize requires input 'str' to be type String, got '" +
                    typeof str +
                    "'."
                );
              }
              return Buffer.byteLength(str, "utf8");
            }
            function arrayContainsArray(superset, subset, some) {
              if (Array.isArray(superset) !== true) {
                throw new Error(
                  "[ethjs-util] method arrayContainsArray requires input 'superset' to be an array got type '" +
                    typeof superset +
                    "'"
                );
              }
              if (Array.isArray(subset) !== true) {
                throw new Error(
                  "[ethjs-util] method arrayContainsArray requires input 'subset' to be an array got type '" +
                    typeof subset +
                    "'"
                );
              }
              return subset[(Boolean(some) && "some") || "every"](function (
                value
              ) {
                return superset.indexOf(value) >= 0;
              });
            }
            function toUtf8(hex) {
              var bufferValue = new Buffer(
                padToEven(stripHexPrefix(hex).replace(/^0+|0+$/g, "")),
                "hex"
              );
              return bufferValue.toString("utf8");
            }
            function toAscii(hex) {
              var str = "";
              var i = 0,
                l = hex.length;
              if (hex.substring(0, 2) === "0x") {
                i = 2;
              }
              for (; i < l; i += 2) {
                var code = parseInt(hex.substr(i, 2), 16);
                str += String.fromCharCode(code);
              }
              return str;
            }
            function fromUtf8(stringValue) {
              var str = new Buffer(stringValue, "utf8");
              return (
                "0x" + padToEven(str.toString("hex")).replace(/^0+|0+$/g, "")
              );
            }
            function fromAscii(stringValue) {
              var hex = "";
              for (var i = 0; i < stringValue.length; i++) {
                var code = stringValue.charCodeAt(i);
                var n = code.toString(16);
                hex += n.length < 2 ? "0" + n : n;
              }
              return "0x" + hex;
            }
            function getKeys(params, key, allowEmpty) {
              if (!Array.isArray(params)) {
                throw new Error(
                  "[ethjs-util] method getKeys expecting type Array as 'params' input, got '" +
                    typeof params +
                    "'"
                );
              }
              if (typeof key !== "string") {
                throw new Error(
                  "[ethjs-util] method getKeys expecting type String for input 'key' got '" +
                    typeof key +
                    "'."
                );
              }
              var result = [];
              for (var i = 0; i < params.length; i++) {
                var value = params[i][key];
                if (allowEmpty && !value) {
                  value = "";
                } else if (typeof value !== "string") {
                  throw new Error("invalid abi");
                }
                result.push(value);
              }
              return result;
            }
            function isHexString(value, length) {
              if (
                typeof value !== "string" ||
                !value.match(/^0x[0-9A-Fa-f]*$/)
              ) {
                return false;
              }
              if (length && value.length !== 2 + 2 * length) {
                return false;
              }
              return true;
            }
            module.exports = {
              arrayContainsArray: arrayContainsArray,
              intToBuffer: intToBuffer,
              getBinarySize: getBinarySize,
              isHexPrefixed: isHexPrefixed,
              stripHexPrefix: stripHexPrefix,
              padToEven: padToEven,
              intToHex: intToHex,
              fromAscii: fromAscii,
              fromUtf8: fromUtf8,
              toAscii: toAscii,
              toUtf8: toUtf8,
              getKeys: getKeys,
              isHexString: isHexString,
            };
          }).call(this);
        }).call(this, require("buffer").Buffer);
      },
      { buffer: 25, "is-hex-prefixed": 95, "strip-hex-prefix": 154 },
    ],
    63: [
      function (require, module, exports) {
        "use strict";
        var R = typeof Reflect === "object" ? Reflect : null;
        var ReflectApply =
          R && typeof R.apply === "function"
            ? R.apply
            : function ReflectApply(target, receiver, args) {
                return Function.prototype.apply.call(target, receiver, args);
              };
        var ReflectOwnKeys;
        if (R && typeof R.ownKeys === "function") {
          ReflectOwnKeys = R.ownKeys;
        } else if (Object.getOwnPropertySymbols) {
          ReflectOwnKeys = function ReflectOwnKeys(target) {
            return Object.getOwnPropertyNames(target).concat(
              Object.getOwnPropertySymbols(target)
            );
          };
        } else {
          ReflectOwnKeys = function ReflectOwnKeys(target) {
            return Object.getOwnPropertyNames(target);
          };
        }
        function ProcessEmitWarning(warning) {
          if (console && console.warn) console.warn(warning);
        }
        var NumberIsNaN =
          Number.isNaN ||
          function NumberIsNaN(value) {
            return value !== value;
          };
        function EventEmitter() {
          EventEmitter.init.call(this);
        }
        module.exports = EventEmitter;
        module.exports.once = once;
        EventEmitter.EventEmitter = EventEmitter;
        EventEmitter.prototype._events = undefined;
        EventEmitter.prototype._eventsCount = 0;
        EventEmitter.prototype._maxListeners = undefined;
        var defaultMaxListeners = 10;
        function checkListener(listener) {
          if (typeof listener !== "function") {
            throw new TypeError(
              'The "listener" argument must be of type Function. Received type ' +
                typeof listener
            );
          }
        }
        Object.defineProperty(EventEmitter, "defaultMaxListeners", {
          enumerable: true,
          get: function () {
            return defaultMaxListeners;
          },
          set: function (arg) {
            if (typeof arg !== "number" || arg < 0 || NumberIsNaN(arg)) {
              throw new RangeError(
                'The value of "defaultMaxListeners" is out of range. It must be a non-negative number. Received ' +
                  arg +
                  "."
              );
            }
            defaultMaxListeners = arg;
          },
        });
        EventEmitter.init = function () {
          if (
            this._events === undefined ||
            this._events === Object.getPrototypeOf(this)._events
          ) {
            this._events = Object.create(null);
            this._eventsCount = 0;
          }
          this._maxListeners = this._maxListeners || undefined;
        };
        EventEmitter.prototype.setMaxListeners = function setMaxListeners(n) {
          if (typeof n !== "number" || n < 0 || NumberIsNaN(n)) {
            throw new RangeError(
              'The value of "n" is out of range. It must be a non-negative number. Received ' +
                n +
                "."
            );
          }
          this._maxListeners = n;
          return this;
        };
        function _getMaxListeners(that) {
          if (that._maxListeners === undefined)
            return EventEmitter.defaultMaxListeners;
          return that._maxListeners;
        }
        EventEmitter.prototype.getMaxListeners = function getMaxListeners() {
          return _getMaxListeners(this);
        };
        EventEmitter.prototype.emit = function emit(type) {
          var args = [];
          for (var i = 1; i < arguments.length; i++) args.push(arguments[i]);
          var doError = type === "error";
          var events = this._events;
          if (events !== undefined)
            doError = doError && events.error === undefined;
          else if (!doError) return false;
          if (doError) {
            var er;
            if (args.length > 0) er = args[0];
            if (er instanceof Error) {
              throw er;
            }
            var err = new Error(
              "Unhandled error." + (er ? " (" + er.message + ")" : "")
            );
            err.context = er;
            throw err;
          }
          var handler = events[type];
          if (handler === undefined) return false;
          if (typeof handler === "function") {
            ReflectApply(handler, this, args);
          } else {
            var len = handler.length;
            var listeners = arrayClone(handler, len);
            for (var i = 0; i < len; ++i)
              ReflectApply(listeners[i], this, args);
          }
          return true;
        };
        function _addListener(target, type, listener, prepend) {
          var m;
          var events;
          var existing;
          checkListener(listener);
          events = target._events;
          if (events === undefined) {
            events = target._events = Object.create(null);
            target._eventsCount = 0;
          } else {
            if (events.newListener !== undefined) {
              target.emit(
                "newListener",
                type,
                listener.listener ? listener.listener : listener
              );
              events = target._events;
            }
            existing = events[type];
          }
          if (existing === undefined) {
            existing = events[type] = listener;
            ++target._eventsCount;
          } else {
            if (typeof existing === "function") {
              existing = events[type] = prepend
                ? [listener, existing]
                : [existing, listener];
            } else if (prepend) {
              existing.unshift(listener);
            } else {
              existing.push(listener);
            }
            m = _getMaxListeners(target);
            if (m > 0 && existing.length > m && !existing.warned) {
              existing.warned = true;
              var w = new Error(
                "Possible EventEmitter memory leak detected. " +
                  existing.length +
                  " " +
                  String(type) +
                  " listeners " +
                  "added. Use emitter.setMaxListeners() to " +
                  "increase limit"
              );
              w.name = "MaxListenersExceededWarning";
              w.emitter = target;
              w.type = type;
              w.count = existing.length;
              ProcessEmitWarning(w);
            }
          }
          return target;
        }
        EventEmitter.prototype.addListener = function addListener(
          type,
          listener
        ) {
          return _addListener(this, type, listener, false);
        };
        EventEmitter.prototype.on = EventEmitter.prototype.addListener;
        EventEmitter.prototype.prependListener = function prependListener(
          type,
          listener
        ) {
          return _addListener(this, type, listener, true);
        };
        function onceWrapper() {
          if (!this.fired) {
            this.target.removeListener(this.type, this.wrapFn);
            this.fired = true;
            if (arguments.length === 0) return this.listener.call(this.target);
            return this.listener.apply(this.target, arguments);
          }
        }
        function _onceWrap(target, type, listener) {
          var state = {
            fired: false,
            wrapFn: undefined,
            target: target,
            type: type,
            listener: listener,
          };
          var wrapped = onceWrapper.bind(state);
          wrapped.listener = listener;
          state.wrapFn = wrapped;
          return wrapped;
        }
        EventEmitter.prototype.once = function once(type, listener) {
          checkListener(listener);
          this.on(type, _onceWrap(this, type, listener));
          return this;
        };
        EventEmitter.prototype.prependOnceListener =
          function prependOnceListener(type, listener) {
            checkListener(listener);
            this.prependListener(type, _onceWrap(this, type, listener));
            return this;
          };
        EventEmitter.prototype.removeListener = function removeListener(
          type,
          listener
        ) {
          var list, events, position, i, originalListener;
          checkListener(listener);
          events = this._events;
          if (events === undefined) return this;
          list = events[type];
          if (list === undefined) return this;
          if (list === listener || list.listener === listener) {
            if (--this._eventsCount === 0) this._events = Object.create(null);
            else {
              delete events[type];
              if (events.removeListener)
                this.emit("removeListener", type, list.listener || listener);
            }
          } else if (typeof list !== "function") {
            position = -1;
            for (i = list.length - 1; i >= 0; i--) {
              if (list[i] === listener || list[i].listener === listener) {
                originalListener = list[i].listener;
                position = i;
                break;
              }
            }
            if (position < 0) return this;
            if (position === 0) list.shift();
            else {
              spliceOne(list, position);
            }
            if (list.length === 1) events[type] = list[0];
            if (events.removeListener !== undefined)
              this.emit("removeListener", type, originalListener || listener);
          }
          return this;
        };
        EventEmitter.prototype.off = EventEmitter.prototype.removeListener;
        EventEmitter.prototype.removeAllListeners = function removeAllListeners(
          type
        ) {
          var listeners, events, i;
          events = this._events;
          if (events === undefined) return this;
          if (events.removeListener === undefined) {
            if (arguments.length === 0) {
              this._events = Object.create(null);
              this._eventsCount = 0;
            } else if (events[type] !== undefined) {
              if (--this._eventsCount === 0) this._events = Object.create(null);
              else delete events[type];
            }
            return this;
          }
          if (arguments.length === 0) {
            var keys = Object.keys(events);
            var key;
            for (i = 0; i < keys.length; ++i) {
              key = keys[i];
              if (key === "removeListener") continue;
              this.removeAllListeners(key);
            }
            this.removeAllListeners("removeListener");
            this._events = Object.create(null);
            this._eventsCount = 0;
            return this;
          }
          listeners = events[type];
          if (typeof listeners === "function") {
            this.removeListener(type, listeners);
          } else if (listeners !== undefined) {
            for (i = listeners.length - 1; i >= 0; i--) {
              this.removeListener(type, listeners[i]);
            }
          }
          return this;
        };
        function _listeners(target, type, unwrap) {
          var events = target._events;
          if (events === undefined) return [];
          var evlistener = events[type];
          if (evlistener === undefined) return [];
          if (typeof evlistener === "function")
            return unwrap ? [evlistener.listener || evlistener] : [evlistener];
          return unwrap
            ? unwrapListeners(evlistener)
            : arrayClone(evlistener, evlistener.length);
        }
        EventEmitter.prototype.listeners = function listeners(type) {
          return _listeners(this, type, true);
        };
        EventEmitter.prototype.rawListeners = function rawListeners(type) {
          return _listeners(this, type, false);
        };
        EventEmitter.listenerCount = function (emitter, type) {
          if (typeof emitter.listenerCount === "function") {
            return emitter.listenerCount(type);
          } else {
            return listenerCount.call(emitter, type);
          }
        };
        EventEmitter.prototype.listenerCount = listenerCount;
        function listenerCount(type) {
          var events = this._events;
          if (events !== undefined) {
            var evlistener = events[type];
            if (typeof evlistener === "function") {
              return 1;
            } else if (evlistener !== undefined) {
              return evlistener.length;
            }
          }
          return 0;
        }
        EventEmitter.prototype.eventNames = function eventNames() {
          return this._eventsCount > 0 ? ReflectOwnKeys(this._events) : [];
        };
        function arrayClone(arr, n) {
          var copy = new Array(n);
          for (var i = 0; i < n; ++i) copy[i] = arr[i];
          return copy;
        }
        function spliceOne(list, index) {
          for (; index + 1 < list.length; index++)
            list[index] = list[index + 1];
          list.pop();
        }
        function unwrapListeners(arr) {
          var ret = new Array(arr.length);
          for (var i = 0; i < ret.length; ++i) {
            ret[i] = arr[i].listener || arr[i];
          }
          return ret;
        }
        function once(emitter, name) {
          return new Promise(function (resolve, reject) {
            function errorListener(err) {
              emitter.removeListener(name, resolver);
              reject(err);
            }
            function resolver() {
              if (typeof emitter.removeListener === "function") {
                emitter.removeListener("error", errorListener);
              }
              resolve([].slice.call(arguments));
            }
            eventTargetAgnosticAddListener(emitter, name, resolver, {
              once: true,
            });
            if (name !== "error") {
              addErrorHandlerIfEventEmitter(emitter, errorListener, {
                once: true,
              });
            }
          });
        }
        function addErrorHandlerIfEventEmitter(emitter, handler, flags) {
          if (typeof emitter.on === "function") {
            eventTargetAgnosticAddListener(emitter, "error", handler, flags);
          }
        }
        function eventTargetAgnosticAddListener(
          emitter,
          name,
          listener,
          flags
        ) {
          if (typeof emitter.on === "function") {
            if (flags.once) {
              emitter.once(name, listener);
            } else {
              emitter.on(name, listener);
            }
          } else if (typeof emitter.addEventListener === "function") {
            emitter.addEventListener(name, function wrapListener(arg) {
              if (flags.once) {
                emitter.removeEventListener(name, wrapListener);
              }
              listener(arg);
            });
          } else {
            throw new TypeError(
              'The "emitter" argument must be of type EventEmitter. Received type ' +
                typeof emitter
            );
          }
        }
      },
      {},
    ],
    64: [
      function (require, module, exports) {
        "use strict";
        var Buffer = require("safe-buffer").Buffer;
        var Transform = require("readable-stream").Transform;
        var inherits = require("inherits");
        function throwIfNotStringOrBuffer(val, prefix) {
          if (!Buffer.isBuffer(val) && typeof val !== "string") {
            throw new TypeError(prefix + " must be a string or a buffer");
          }
        }
        function HashBase(blockSize) {
          Transform.call(this);
          this._block = Buffer.allocUnsafe(blockSize);
          this._blockSize = blockSize;
          this._blockOffset = 0;
          this._length = [0, 0, 0, 0];
          this._finalized = false;
        }
        inherits(HashBase, Transform);
        HashBase.prototype._transform = function (chunk, encoding, callback) {
          var error = null;
          try {
            this.update(chunk, encoding);
          } catch (err) {
            error = err;
          }
          callback(error);
        };
        HashBase.prototype._flush = function (callback) {
          var error = null;
          try {
            this.push(this.digest());
          } catch (err) {
            error = err;
          }
          callback(error);
        };
        HashBase.prototype.update = function (data, encoding) {
          throwIfNotStringOrBuffer(data, "Data");
          if (this._finalized) throw new Error("Digest already called");
          if (!Buffer.isBuffer(data)) data = Buffer.from(data, encoding);
          var block = this._block;
          var offset = 0;
          while (this._blockOffset + data.length - offset >= this._blockSize) {
            for (var i = this._blockOffset; i < this._blockSize; )
              block[i++] = data[offset++];
            this._update();
            this._blockOffset = 0;
          }
          while (offset < data.length)
            block[this._blockOffset++] = data[offset++];
          for (var j = 0, carry = data.length * 8; carry > 0; ++j) {
            this._length[j] += carry;
            carry = (this._length[j] / 4294967296) | 0;
            if (carry > 0) this._length[j] -= 4294967296 * carry;
          }
          return this;
        };
        HashBase.prototype._update = function () {
          throw new Error("_update is not implemented");
        };
        HashBase.prototype.digest = function (encoding) {
          if (this._finalized) throw new Error("Digest already called");
          this._finalized = true;
          var digest = this._digest();
          if (encoding !== undefined) digest = digest.toString(encoding);
          this._block.fill(0);
          this._blockOffset = 0;
          for (var i = 0; i < 4; ++i) this._length[i] = 0;
          return digest;
        };
        HashBase.prototype._digest = function () {
          throw new Error("_digest is not implemented");
        };
        module.exports = HashBase;
      },
      { inherits: 94, "readable-stream": 79, "safe-buffer": 126 },
    ],
    65: [
      function (require, module, exports) {
        "use strict";
        function _inheritsLoose(subClass, superClass) {
          subClass.prototype = Object.create(superClass.prototype);
          subClass.prototype.constructor = subClass;
          subClass.__proto__ = superClass;
        }
        var codes = {};
        function createErrorType(code, message, Base) {
          if (!Base) {
            Base = Error;
          }
          function getMessage(arg1, arg2, arg3) {
            if (typeof message === "string") {
              return message;
            } else {
              return message(arg1, arg2, arg3);
            }
          }
          var NodeError = (function (_Base) {
            _inheritsLoose(NodeError, _Base);
            function NodeError(arg1, arg2, arg3) {
              return _Base.call(this, getMessage(arg1, arg2, arg3)) || this;
            }
            return NodeError;
          })(Base);
          NodeError.prototype.name = Base.name;
          NodeError.prototype.code = code;
          codes[code] = NodeError;
        }
        function oneOf(expected, thing) {
          if (Array.isArray(expected)) {
            var len = expected.length;
            expected = expected.map(function (i) {
              return String(i);
            });
            if (len > 2) {
              return (
                "one of "
                  .concat(thing, " ")
                  .concat(expected.slice(0, len - 1).join(", "), ", or ") +
                expected[len - 1]
              );
            } else if (len === 2) {
              return "one of "
                .concat(thing, " ")
                .concat(expected[0], " or ")
                .concat(expected[1]);
            } else {
              return "of ".concat(thing, " ").concat(expected[0]);
            }
          } else {
            return "of ".concat(thing, " ").concat(String(expected));
          }
        }
        function startsWith(str, search, pos) {
          return (
            str.substr(!pos || pos < 0 ? 0 : +pos, search.length) === search
          );
        }
        function endsWith(str, search, this_len) {
          if (this_len === undefined || this_len > str.length) {
            this_len = str.length;
          }
          return str.substring(this_len - search.length, this_len) === search;
        }
        function includes(str, search, start) {
          if (typeof start !== "number") {
            start = 0;
          }
          if (start + search.length > str.length) {
            return false;
          } else {
            return str.indexOf(search, start) !== -1;
          }
        }
        createErrorType(
          "ERR_INVALID_OPT_VALUE",
          function (name, value) {
            return (
              'The value "' + value + '" is invalid for option "' + name + '"'
            );
          },
          TypeError
        );
        createErrorType(
          "ERR_INVALID_ARG_TYPE",
          function (name, expected, actual) {
            var determiner;
            if (typeof expected === "string" && startsWith(expected, "not ")) {
              determiner = "must not be";
              expected = expected.replace(/^not /, "");
            } else {
              determiner = "must be";
            }
            var msg;
            if (endsWith(name, " argument")) {
              msg = "The "
                .concat(name, " ")
                .concat(determiner, " ")
                .concat(oneOf(expected, "type"));
            } else {
              var type = includes(name, ".") ? "property" : "argument";
              msg = 'The "'
                .concat(name, '" ')
                .concat(type, " ")
                .concat(determiner, " ")
                .concat(oneOf(expected, "type"));
            }
            msg += ". Received type ".concat(typeof actual);
            return msg;
          },
          TypeError
        );
        createErrorType("ERR_STREAM_PUSH_AFTER_EOF", "stream.push() after EOF");
        createErrorType("ERR_METHOD_NOT_IMPLEMENTED", function (name) {
          return "The " + name + " method is not implemented";
        });
        createErrorType("ERR_STREAM_PREMATURE_CLOSE", "Premature close");
        createErrorType("ERR_STREAM_DESTROYED", function (name) {
          return "Cannot call " + name + " after a stream was destroyed";
        });
        createErrorType(
          "ERR_MULTIPLE_CALLBACK",
          "Callback called multiple times"
        );
        createErrorType("ERR_STREAM_CANNOT_PIPE", "Cannot pipe, not readable");
        createErrorType("ERR_STREAM_WRITE_AFTER_END", "write after end");
        createErrorType(
          "ERR_STREAM_NULL_VALUES",
          "May not write null values to stream",
          TypeError
        );
        createErrorType(
          "ERR_UNKNOWN_ENCODING",
          function (arg) {
            return "Unknown encoding: " + arg;
          },
          TypeError
        );
        createErrorType(
          "ERR_STREAM_UNSHIFT_AFTER_END_EVENT",
          "stream.unshift() after end event"
        );
        module.exports.codes = codes;
      },
      {},
    ],
    66: [
      function (require, module, exports) {
        (function (process) {
          (function () {
            "use strict";
            var objectKeys =
              Object.keys ||
              function (obj) {
                var keys = [];
                for (var key in obj) {
                  keys.push(key);
                }
                return keys;
              };
            module.exports = Duplex;
            var Readable = require("./_stream_readable");
            var Writable = require("./_stream_writable");
            require("inherits")(Duplex, Readable);
            {
              var keys = objectKeys(Writable.prototype);
              for (var v = 0; v < keys.length; v++) {
                var method = keys[v];
                if (!Duplex.prototype[method])
                  Duplex.prototype[method] = Writable.prototype[method];
              }
            }
            function Duplex(options) {
              if (!(this instanceof Duplex)) return new Duplex(options);
              Readable.call(this, options);
              Writable.call(this, options);
              this.allowHalfOpen = true;
              if (options) {
                if (options.readable === false) this.readable = false;
                if (options.writable === false) this.writable = false;
                if (options.allowHalfOpen === false) {
                  this.allowHalfOpen = false;
                  this.once("end", onend);
                }
              }
            }
            Object.defineProperty(Duplex.prototype, "writableHighWaterMark", {
              enumerable: false,
              get: function get() {
                return this._writableState.highWaterMark;
              },
            });
            Object.defineProperty(Duplex.prototype, "writableBuffer", {
              enumerable: false,
              get: function get() {
                return this._writableState && this._writableState.getBuffer();
              },
            });
            Object.defineProperty(Duplex.prototype, "writableLength", {
              enumerable: false,
              get: function get() {
                return this._writableState.length;
              },
            });
            function onend() {
              if (this._writableState.ended) return;
              process.nextTick(onEndNT, this);
            }
            function onEndNT(self) {
              self.end();
            }
            Object.defineProperty(Duplex.prototype, "destroyed", {
              enumerable: false,
              get: function get() {
                if (
                  this._readableState === undefined ||
                  this._writableState === undefined
                ) {
                  return false;
                }
                return (
                  this._readableState.destroyed && this._writableState.destroyed
                );
              },
              set: function set(value) {
                if (
                  this._readableState === undefined ||
                  this._writableState === undefined
                ) {
                  return;
                }
                this._readableState.destroyed = value;
                this._writableState.destroyed = value;
              },
            });
          }).call(this);
        }).call(this, require("_process"));
      },
      {
        "./_stream_readable": 68,
        "./_stream_writable": 70,
        _process: 122,
        inherits: 94,
      },
    ],
    67: [
      function (require, module, exports) {
        "use strict";
        module.exports = PassThrough;
        var Transform = require("./_stream_transform");
        require("inherits")(PassThrough, Transform);
        function PassThrough(options) {
          if (!(this instanceof PassThrough)) return new PassThrough(options);
          Transform.call(this, options);
        }
        PassThrough.prototype._transform = function (chunk, encoding, cb) {
          cb(null, chunk);
        };
      },
      { "./_stream_transform": 69, inherits: 94 },
    ],
    68: [
      function (require, module, exports) {
        (function (process, global) {
          (function () {
            "use strict";
            module.exports = Readable;
            var Duplex;
            Readable.ReadableState = ReadableState;
            var EE = require("events").EventEmitter;
            var EElistenerCount = function EElistenerCount(emitter, type) {
              return emitter.listeners(type).length;
            };
            var Stream = require("./internal/streams/stream");
            var Buffer = require("buffer").Buffer;
            var OurUint8Array = global.Uint8Array || function () {};
            function _uint8ArrayToBuffer(chunk) {
              return Buffer.from(chunk);
            }
            function _isUint8Array(obj) {
              return Buffer.isBuffer(obj) || obj instanceof OurUint8Array;
            }
            var debugUtil = require("util");
            var debug;
            if (debugUtil && debugUtil.debuglog) {
              debug = debugUtil.debuglog("stream");
            } else {
              debug = function debug() {};
            }
            var BufferList = require("./internal/streams/buffer_list");
            var destroyImpl = require("./internal/streams/destroy");
            var _require = require("./internal/streams/state"),
              getHighWaterMark = _require.getHighWaterMark;
            var _require$codes = require("../errors").codes,
              ERR_INVALID_ARG_TYPE = _require$codes.ERR_INVALID_ARG_TYPE,
              ERR_STREAM_PUSH_AFTER_EOF =
                _require$codes.ERR_STREAM_PUSH_AFTER_EOF,
              ERR_METHOD_NOT_IMPLEMENTED =
                _require$codes.ERR_METHOD_NOT_IMPLEMENTED,
              ERR_STREAM_UNSHIFT_AFTER_END_EVENT =
                _require$codes.ERR_STREAM_UNSHIFT_AFTER_END_EVENT;
            var StringDecoder;
            var createReadableStreamAsyncIterator;
            var from;
            require("inherits")(Readable, Stream);
            var errorOrDestroy = destroyImpl.errorOrDestroy;
            var kProxyEvents = ["error", "close", "destroy", "pause", "resume"];
            function prependListener(emitter, event, fn) {
              if (typeof emitter.prependListener === "function")
                return emitter.prependListener(event, fn);
              if (!emitter._events || !emitter._events[event])
                emitter.on(event, fn);
              else if (Array.isArray(emitter._events[event]))
                emitter._events[event].unshift(fn);
              else emitter._events[event] = [fn, emitter._events[event]];
            }
            function ReadableState(options, stream, isDuplex) {
              Duplex = Duplex || require("./_stream_duplex");
              options = options || {};
              if (typeof isDuplex !== "boolean")
                isDuplex = stream instanceof Duplex;
              this.objectMode = !!options.objectMode;
              if (isDuplex)
                this.objectMode =
                  this.objectMode || !!options.readableObjectMode;
              this.highWaterMark = getHighWaterMark(
                this,
                options,
                "readableHighWaterMark",
                isDuplex
              );
              this.buffer = new BufferList();
              this.length = 0;
              this.pipes = null;
              this.pipesCount = 0;
              this.flowing = null;
              this.ended = false;
              this.endEmitted = false;
              this.reading = false;
              this.sync = true;
              this.needReadable = false;
              this.emittedReadable = false;
              this.readableListening = false;
              this.resumeScheduled = false;
              this.paused = true;
              this.emitClose = options.emitClose !== false;
              this.autoDestroy = !!options.autoDestroy;
              this.destroyed = false;
              this.defaultEncoding = options.defaultEncoding || "utf8";
              this.awaitDrain = 0;
              this.readingMore = false;
              this.decoder = null;
              this.encoding = null;
              if (options.encoding) {
                if (!StringDecoder)
                  StringDecoder = require("string_decoder/").StringDecoder;
                this.decoder = new StringDecoder(options.encoding);
                this.encoding = options.encoding;
              }
            }
            function Readable(options) {
              Duplex = Duplex || require("./_stream_duplex");
              if (!(this instanceof Readable)) return new Readable(options);
              var isDuplex = this instanceof Duplex;
              this._readableState = new ReadableState(options, this, isDuplex);
              this.readable = true;
              if (options) {
                if (typeof options.read === "function")
                  this._read = options.read;
                if (typeof options.destroy === "function")
                  this._destroy = options.destroy;
              }
              Stream.call(this);
            }
            Object.defineProperty(Readable.prototype, "destroyed", {
              enumerable: false,
              get: function get() {
                if (this._readableState === undefined) {
                  return false;
                }
                return this._readableState.destroyed;
              },
              set: function set(value) {
                if (!this._readableState) {
                  return;
                }
                this._readableState.destroyed = value;
              },
            });
            Readable.prototype.destroy = destroyImpl.destroy;
            Readable.prototype._undestroy = destroyImpl.undestroy;
            Readable.prototype._destroy = function (err, cb) {
              cb(err);
            };
            Readable.prototype.push = function (chunk, encoding) {
              var state = this._readableState;
              var skipChunkCheck;
              if (!state.objectMode) {
                if (typeof chunk === "string") {
                  encoding = encoding || state.defaultEncoding;
                  if (encoding !== state.encoding) {
                    chunk = Buffer.from(chunk, encoding);
                    encoding = "";
                  }
                  skipChunkCheck = true;
                }
              } else {
                skipChunkCheck = true;
              }
              return readableAddChunk(
                this,
                chunk,
                encoding,
                false,
                skipChunkCheck
              );
            };
            Readable.prototype.unshift = function (chunk) {
              return readableAddChunk(this, chunk, null, true, false);
            };
            function readableAddChunk(
              stream,
              chunk,
              encoding,
              addToFront,
              skipChunkCheck
            ) {
              debug("readableAddChunk", chunk);
              var state = stream._readableState;
              if (chunk === null) {
                state.reading = false;
                onEofChunk(stream, state);
              } else {
                var er;
                if (!skipChunkCheck) er = chunkInvalid(state, chunk);
                if (er) {
                  errorOrDestroy(stream, er);
                } else if (state.objectMode || (chunk && chunk.length > 0)) {
                  if (
                    typeof chunk !== "string" &&
                    !state.objectMode &&
                    Object.getPrototypeOf(chunk) !== Buffer.prototype
                  ) {
                    chunk = _uint8ArrayToBuffer(chunk);
                  }
                  if (addToFront) {
                    if (state.endEmitted)
                      errorOrDestroy(
                        stream,
                        new ERR_STREAM_UNSHIFT_AFTER_END_EVENT()
                      );
                    else addChunk(stream, state, chunk, true);
                  } else if (state.ended) {
                    errorOrDestroy(stream, new ERR_STREAM_PUSH_AFTER_EOF());
                  } else if (state.destroyed) {
                    return false;
                  } else {
                    state.reading = false;
                    if (state.decoder && !encoding) {
                      chunk = state.decoder.write(chunk);
                      if (state.objectMode || chunk.length !== 0)
                        addChunk(stream, state, chunk, false);
                      else maybeReadMore(stream, state);
                    } else {
                      addChunk(stream, state, chunk, false);
                    }
                  }
                } else if (!addToFront) {
                  state.reading = false;
                  maybeReadMore(stream, state);
                }
              }
              return (
                !state.ended &&
                (state.length < state.highWaterMark || state.length === 0)
              );
            }
            function addChunk(stream, state, chunk, addToFront) {
              if (state.flowing && state.length === 0 && !state.sync) {
                state.awaitDrain = 0;
                stream.emit("data", chunk);
              } else {
                state.length += state.objectMode ? 1 : chunk.length;
                if (addToFront) state.buffer.unshift(chunk);
                else state.buffer.push(chunk);
                if (state.needReadable) emitReadable(stream);
              }
              maybeReadMore(stream, state);
            }
            function chunkInvalid(state, chunk) {
              var er;
              if (
                !_isUint8Array(chunk) &&
                typeof chunk !== "string" &&
                chunk !== undefined &&
                !state.objectMode
              ) {
                er = new ERR_INVALID_ARG_TYPE(
                  "chunk",
                  ["string", "Buffer", "Uint8Array"],
                  chunk
                );
              }
              return er;
            }
            Readable.prototype.isPaused = function () {
              return this._readableState.flowing === false;
            };
            Readable.prototype.setEncoding = function (enc) {
              if (!StringDecoder)
                StringDecoder = require("string_decoder/").StringDecoder;
              var decoder = new StringDecoder(enc);
              this._readableState.decoder = decoder;
              this._readableState.encoding =
                this._readableState.decoder.encoding;
              var p = this._readableState.buffer.head;
              var content = "";
              while (p !== null) {
                content += decoder.write(p.data);
                p = p.next;
              }
              this._readableState.buffer.clear();
              if (content !== "") this._readableState.buffer.push(content);
              this._readableState.length = content.length;
              return this;
            };
            var MAX_HWM = 1073741824;
            function computeNewHighWaterMark(n) {
              if (n >= MAX_HWM) {
                n = MAX_HWM;
              } else {
                n--;
                n |= n >>> 1;
                n |= n >>> 2;
                n |= n >>> 4;
                n |= n >>> 8;
                n |= n >>> 16;
                n++;
              }
              return n;
            }
            function howMuchToRead(n, state) {
              if (n <= 0 || (state.length === 0 && state.ended)) return 0;
              if (state.objectMode) return 1;
              if (n !== n) {
                if (state.flowing && state.length)
                  return state.buffer.head.data.length;
                else return state.length;
              }
              if (n > state.highWaterMark)
                state.highWaterMark = computeNewHighWaterMark(n);
              if (n <= state.length) return n;
              if (!state.ended) {
                state.needReadable = true;
                return 0;
              }
              return state.length;
            }
            Readable.prototype.read = function (n) {
              debug("read", n);
              n = parseInt(n, 10);
              var state = this._readableState;
              var nOrig = n;
              if (n !== 0) state.emittedReadable = false;
              if (
                n === 0 &&
                state.needReadable &&
                ((state.highWaterMark !== 0
                  ? state.length >= state.highWaterMark
                  : state.length > 0) ||
                  state.ended)
              ) {
                debug("read: emitReadable", state.length, state.ended);
                if (state.length === 0 && state.ended) endReadable(this);
                else emitReadable(this);
                return null;
              }
              n = howMuchToRead(n, state);
              if (n === 0 && state.ended) {
                if (state.length === 0) endReadable(this);
                return null;
              }
              var doRead = state.needReadable;
              debug("need readable", doRead);
              if (
                state.length === 0 ||
                state.length - n < state.highWaterMark
              ) {
                doRead = true;
                debug("length less than watermark", doRead);
              }
              if (state.ended || state.reading) {
                doRead = false;
                debug("reading or ended", doRead);
              } else if (doRead) {
                debug("do read");
                state.reading = true;
                state.sync = true;
                if (state.length === 0) state.needReadable = true;
                this._read(state.highWaterMark);
                state.sync = false;
                if (!state.reading) n = howMuchToRead(nOrig, state);
              }
              var ret;
              if (n > 0) ret = fromList(n, state);
              else ret = null;
              if (ret === null) {
                state.needReadable = state.length <= state.highWaterMark;
                n = 0;
              } else {
                state.length -= n;
                state.awaitDrain = 0;
              }
              if (state.length === 0) {
                if (!state.ended) state.needReadable = true;
                if (nOrig !== n && state.ended) endReadable(this);
              }
              if (ret !== null) this.emit("data", ret);
              return ret;
            };
            function onEofChunk(stream, state) {
              debug("onEofChunk");
              if (state.ended) return;
              if (state.decoder) {
                var chunk = state.decoder.end();
                if (chunk && chunk.length) {
                  state.buffer.push(chunk);
                  state.length += state.objectMode ? 1 : chunk.length;
                }
              }
              state.ended = true;
              if (state.sync) {
                emitReadable(stream);
              } else {
                state.needReadable = false;
                if (!state.emittedReadable) {
                  state.emittedReadable = true;
                  emitReadable_(stream);
                }
              }
            }
            function emitReadable(stream) {
              var state = stream._readableState;
              debug("emitReadable", state.needReadable, state.emittedReadable);
              state.needReadable = false;
              if (!state.emittedReadable) {
                debug("emitReadable", state.flowing);
                state.emittedReadable = true;
                process.nextTick(emitReadable_, stream);
              }
            }
            function emitReadable_(stream) {
              var state = stream._readableState;
              debug(
                "emitReadable_",
                state.destroyed,
                state.length,
                state.ended
              );
              if (!state.destroyed && (state.length || state.ended)) {
                stream.emit("readable");
                state.emittedReadable = false;
              }
              state.needReadable =
                !state.flowing &&
                !state.ended &&
                state.length <= state.highWaterMark;
              flow(stream);
            }
            function maybeReadMore(stream, state) {
              if (!state.readingMore) {
                state.readingMore = true;
                process.nextTick(maybeReadMore_, stream, state);
              }
            }
            function maybeReadMore_(stream, state) {
              while (
                !state.reading &&
                !state.ended &&
                (state.length < state.highWaterMark ||
                  (state.flowing && state.length === 0))
              ) {
                var len = state.length;
                debug("maybeReadMore read 0");
                stream.read(0);
                if (len === state.length) break;
              }
              state.readingMore = false;
            }
            Readable.prototype._read = function (n) {
              errorOrDestroy(this, new ERR_METHOD_NOT_IMPLEMENTED("_read()"));
            };
            Readable.prototype.pipe = function (dest, pipeOpts) {
              var src = this;
              var state = this._readableState;
              switch (state.pipesCount) {
                case 0:
                  state.pipes = dest;
                  break;
                case 1:
                  state.pipes = [state.pipes, dest];
                  break;
                default:
                  state.pipes.push(dest);
                  break;
              }
              state.pipesCount += 1;
              debug("pipe count=%d opts=%j", state.pipesCount, pipeOpts);
              var doEnd =
                (!pipeOpts || pipeOpts.end !== false) &&
                dest !== process.stdout &&
                dest !== process.stderr;
              var endFn = doEnd ? onend : unpipe;
              if (state.endEmitted) process.nextTick(endFn);
              else src.once("end", endFn);
              dest.on("unpipe", onunpipe);
              function onunpipe(readable, unpipeInfo) {
                debug("onunpipe");
                if (readable === src) {
                  if (unpipeInfo && unpipeInfo.hasUnpiped === false) {
                    unpipeInfo.hasUnpiped = true;
                    cleanup();
                  }
                }
              }
              function onend() {
                debug("onend");
                dest.end();
              }
              var ondrain = pipeOnDrain(src);
              dest.on("drain", ondrain);
              var cleanedUp = false;
              function cleanup() {
                debug("cleanup");
                dest.removeListener("close", onclose);
                dest.removeListener("finish", onfinish);
                dest.removeListener("drain", ondrain);
                dest.removeListener("error", onerror);
                dest.removeListener("unpipe", onunpipe);
                src.removeListener("end", onend);
                src.removeListener("end", unpipe);
                src.removeListener("data", ondata);
                cleanedUp = true;
                if (
                  state.awaitDrain &&
                  (!dest._writableState || dest._writableState.needDrain)
                )
                  ondrain();
              }
              src.on("data", ondata);
              function ondata(chunk) {
                debug("ondata");
                var ret = dest.write(chunk);
                debug("dest.write", ret);
                if (ret === false) {
                  if (
                    ((state.pipesCount === 1 && state.pipes === dest) ||
                      (state.pipesCount > 1 &&
                        indexOf(state.pipes, dest) !== -1)) &&
                    !cleanedUp
                  ) {
                    debug("false write response, pause", state.awaitDrain);
                    state.awaitDrain++;
                  }
                  src.pause();
                }
              }
              function onerror(er) {
                debug("onerror", er);
                unpipe();
                dest.removeListener("error", onerror);
                if (EElistenerCount(dest, "error") === 0)
                  errorOrDestroy(dest, er);
              }
              prependListener(dest, "error", onerror);
              function onclose() {
                dest.removeListener("finish", onfinish);
                unpipe();
              }
              dest.once("close", onclose);
              function onfinish() {
                debug("onfinish");
                dest.removeListener("close", onclose);
                unpipe();
              }
              dest.once("finish", onfinish);
              function unpipe() {
                debug("unpipe");
                src.unpipe(dest);
              }
              dest.emit("pipe", src);
              if (!state.flowing) {
                debug("pipe resume");
                src.resume();
              }
              return dest;
            };
            function pipeOnDrain(src) {
              return function pipeOnDrainFunctionResult() {
                var state = src._readableState;
                debug("pipeOnDrain", state.awaitDrain);
                if (state.awaitDrain) state.awaitDrain--;
                if (state.awaitDrain === 0 && EElistenerCount(src, "data")) {
                  state.flowing = true;
                  flow(src);
                }
              };
            }
            Readable.prototype.unpipe = function (dest) {
              var state = this._readableState;
              var unpipeInfo = { hasUnpiped: false };
              if (state.pipesCount === 0) return this;
              if (state.pipesCount === 1) {
                if (dest && dest !== state.pipes) return this;
                if (!dest) dest = state.pipes;
                state.pipes = null;
                state.pipesCount = 0;
                state.flowing = false;
                if (dest) dest.emit("unpipe", this, unpipeInfo);
                return this;
              }
              if (!dest) {
                var dests = state.pipes;
                var len = state.pipesCount;
                state.pipes = null;
                state.pipesCount = 0;
                state.flowing = false;
                for (var i = 0; i < len; i++) {
                  dests[i].emit("unpipe", this, { hasUnpiped: false });
                }
                return this;
              }
              var index = indexOf(state.pipes, dest);
              if (index === -1) return this;
              state.pipes.splice(index, 1);
              state.pipesCount -= 1;
              if (state.pipesCount === 1) state.pipes = state.pipes[0];
              dest.emit("unpipe", this, unpipeInfo);
              return this;
            };
            Readable.prototype.on = function (ev, fn) {
              var res = Stream.prototype.on.call(this, ev, fn);
              var state = this._readableState;
              if (ev === "data") {
                state.readableListening = this.listenerCount("readable") > 0;
                if (state.flowing !== false) this.resume();
              } else if (ev === "readable") {
                if (!state.endEmitted && !state.readableListening) {
                  state.readableListening = state.needReadable = true;
                  state.flowing = false;
                  state.emittedReadable = false;
                  debug("on readable", state.length, state.reading);
                  if (state.length) {
                    emitReadable(this);
                  } else if (!state.reading) {
                    process.nextTick(nReadingNextTick, this);
                  }
                }
              }
              return res;
            };
            Readable.prototype.addListener = Readable.prototype.on;
            Readable.prototype.removeListener = function (ev, fn) {
              var res = Stream.prototype.removeListener.call(this, ev, fn);
              if (ev === "readable") {
                process.nextTick(updateReadableListening, this);
              }
              return res;
            };
            Readable.prototype.removeAllListeners = function (ev) {
              var res = Stream.prototype.removeAllListeners.apply(
                this,
                arguments
              );
              if (ev === "readable" || ev === undefined) {
                process.nextTick(updateReadableListening, this);
              }
              return res;
            };
            function updateReadableListening(self) {
              var state = self._readableState;
              state.readableListening = self.listenerCount("readable") > 0;
              if (state.resumeScheduled && !state.paused) {
                state.flowing = true;
              } else if (self.listenerCount("data") > 0) {
                self.resume();
              }
            }
            function nReadingNextTick(self) {
              debug("readable nexttick read 0");
              self.read(0);
            }
            Readable.prototype.resume = function () {
              var state = this._readableState;
              if (!state.flowing) {
                debug("resume");
                state.flowing = !state.readableListening;
                resume(this, state);
              }
              state.paused = false;
              return this;
            };
            function resume(stream, state) {
              if (!state.resumeScheduled) {
                state.resumeScheduled = true;
                process.nextTick(resume_, stream, state);
              }
            }
            function resume_(stream, state) {
              debug("resume", state.reading);
              if (!state.reading) {
                stream.read(0);
              }
              state.resumeScheduled = false;
              stream.emit("resume");
              flow(stream);
              if (state.flowing && !state.reading) stream.read(0);
            }
            Readable.prototype.pause = function () {
              debug("call pause flowing=%j", this._readableState.flowing);
              if (this._readableState.flowing !== false) {
                debug("pause");
                this._readableState.flowing = false;
                this.emit("pause");
              }
              this._readableState.paused = true;
              return this;
            };
            function flow(stream) {
              var state = stream._readableState;
              debug("flow", state.flowing);
              while (state.flowing && stream.read() !== null) {}
            }
            Readable.prototype.wrap = function (stream) {
              var _this = this;
              var state = this._readableState;
              var paused = false;
              stream.on("end", function () {
                debug("wrapped end");
                if (state.decoder && !state.ended) {
                  var chunk = state.decoder.end();
                  if (chunk && chunk.length) _this.push(chunk);
                }
                _this.push(null);
              });
              stream.on("data", function (chunk) {
                debug("wrapped data");
                if (state.decoder) chunk = state.decoder.write(chunk);
                if (state.objectMode && (chunk === null || chunk === undefined))
                  return;
                else if (!state.objectMode && (!chunk || !chunk.length)) return;
                var ret = _this.push(chunk);
                if (!ret) {
                  paused = true;
                  stream.pause();
                }
              });
              for (var i in stream) {
                if (this[i] === undefined && typeof stream[i] === "function") {
                  this[i] = (function methodWrap(method) {
                    return function methodWrapReturnFunction() {
                      return stream[method].apply(stream, arguments);
                    };
                  })(i);
                }
              }
              for (var n = 0; n < kProxyEvents.length; n++) {
                stream.on(
                  kProxyEvents[n],
                  this.emit.bind(this, kProxyEvents[n])
                );
              }
              this._read = function (n) {
                debug("wrapped _read", n);
                if (paused) {
                  paused = false;
                  stream.resume();
                }
              };
              return this;
            };
            if (typeof Symbol === "function") {
              Readable.prototype[Symbol.asyncIterator] = function () {
                if (createReadableStreamAsyncIterator === undefined) {
                  createReadableStreamAsyncIterator = require("./internal/streams/async_iterator");
                }
                return createReadableStreamAsyncIterator(this);
              };
            }
            Object.defineProperty(Readable.prototype, "readableHighWaterMark", {
              enumerable: false,
              get: function get() {
                return this._readableState.highWaterMark;
              },
            });
            Object.defineProperty(Readable.prototype, "readableBuffer", {
              enumerable: false,
              get: function get() {
                return this._readableState && this._readableState.buffer;
              },
            });
            Object.defineProperty(Readable.prototype, "readableFlowing", {
              enumerable: false,
              get: function get() {
                return this._readableState.flowing;
              },
              set: function set(state) {
                if (this._readableState) {
                  this._readableState.flowing = state;
                }
              },
            });
            Readable._fromList = fromList;
            Object.defineProperty(Readable.prototype, "readableLength", {
              enumerable: false,
              get: function get() {
                return this._readableState.length;
              },
            });
            function fromList(n, state) {
              if (state.length === 0) return null;
              var ret;
              if (state.objectMode) ret = state.buffer.shift();
              else if (!n || n >= state.length) {
                if (state.decoder) ret = state.buffer.join("");
                else if (state.buffer.length === 1) ret = state.buffer.first();
                else ret = state.buffer.concat(state.length);
                state.buffer.clear();
              } else {
                ret = state.buffer.consume(n, state.decoder);
              }
              return ret;
            }
            function endReadable(stream) {
              var state = stream._readableState;
              debug("endReadable", state.endEmitted);
              if (!state.endEmitted) {
                state.ended = true;
                process.nextTick(endReadableNT, state, stream);
              }
            }
            function endReadableNT(state, stream) {
              debug("endReadableNT", state.endEmitted, state.length);
              if (!state.endEmitted && state.length === 0) {
                state.endEmitted = true;
                stream.readable = false;
                stream.emit("end");
                if (state.autoDestroy) {
                  var wState = stream._writableState;
                  if (!wState || (wState.autoDestroy && wState.finished)) {
                    stream.destroy();
                  }
                }
              }
            }
            if (typeof Symbol === "function") {
              Readable.from = function (iterable, opts) {
                if (from === undefined) {
                  from = require("./internal/streams/from");
                }
                return from(Readable, iterable, opts);
              };
            }
            function indexOf(xs, x) {
              for (var i = 0, l = xs.length; i < l; i++) {
                if (xs[i] === x) return i;
              }
              return -1;
            }
          }).call(this);
        }).call(
          this,
          require("_process"),
          typeof global !== "undefined"
            ? global
            : typeof self !== "undefined"
            ? self
            : typeof window !== "undefined"
            ? window
            : {}
        );
      },
      {
        "../errors": 65,
        "./_stream_duplex": 66,
        "./internal/streams/async_iterator": 71,
        "./internal/streams/buffer_list": 72,
        "./internal/streams/destroy": 73,
        "./internal/streams/from": 75,
        "./internal/streams/state": 77,
        "./internal/streams/stream": 78,
        _process: 122,
        buffer: 25,
        events: 63,
        inherits: 94,
        "string_decoder/": 153,
        util: 24,
      },
    ],
    69: [
      function (require, module, exports) {
        "use strict";
        module.exports = Transform;
        var _require$codes = require("../errors").codes,
          ERR_METHOD_NOT_IMPLEMENTED =
            _require$codes.ERR_METHOD_NOT_IMPLEMENTED,
          ERR_MULTIPLE_CALLBACK = _require$codes.ERR_MULTIPLE_CALLBACK,
          ERR_TRANSFORM_ALREADY_TRANSFORMING =
            _require$codes.ERR_TRANSFORM_ALREADY_TRANSFORMING,
          ERR_TRANSFORM_WITH_LENGTH_0 =
            _require$codes.ERR_TRANSFORM_WITH_LENGTH_0;
        var Duplex = require("./_stream_duplex");
        require("inherits")(Transform, Duplex);
        function afterTransform(er, data) {
          var ts = this._transformState;
          ts.transforming = false;
          var cb = ts.writecb;
          if (cb === null) {
            return this.emit("error", new ERR_MULTIPLE_CALLBACK());
          }
          ts.writechunk = null;
          ts.writecb = null;
          if (data != null) this.push(data);
          cb(er);
          var rs = this._readableState;
          rs.reading = false;
          if (rs.needReadable || rs.length < rs.highWaterMark) {
            this._read(rs.highWaterMark);
          }
        }
        function Transform(options) {
          if (!(this instanceof Transform)) return new Transform(options);
          Duplex.call(this, options);
          this._transformState = {
            afterTransform: afterTransform.bind(this),
            needTransform: false,
            transforming: false,
            writecb: null,
            writechunk: null,
            writeencoding: null,
          };
          this._readableState.needReadable = true;
          this._readableState.sync = false;
          if (options) {
            if (typeof options.transform === "function")
              this._transform = options.transform;
            if (typeof options.flush === "function")
              this._flush = options.flush;
          }
          this.on("prefinish", prefinish);
        }
        function prefinish() {
          var _this = this;
          if (
            typeof this._flush === "function" &&
            !this._readableState.destroyed
          ) {
            this._flush(function (er, data) {
              done(_this, er, data);
            });
          } else {
            done(this, null, null);
          }
        }
        Transform.prototype.push = function (chunk, encoding) {
          this._transformState.needTransform = false;
          return Duplex.prototype.push.call(this, chunk, encoding);
        };
        Transform.prototype._transform = function (chunk, encoding, cb) {
          cb(new ERR_METHOD_NOT_IMPLEMENTED("_transform()"));
        };
        Transform.prototype._write = function (chunk, encoding, cb) {
          var ts = this._transformState;
          ts.writecb = cb;
          ts.writechunk = chunk;
          ts.writeencoding = encoding;
          if (!ts.transforming) {
            var rs = this._readableState;
            if (
              ts.needTransform ||
              rs.needReadable ||
              rs.length < rs.highWaterMark
            )
              this._read(rs.highWaterMark);
          }
        };
        Transform.prototype._read = function (n) {
          var ts = this._transformState;
          if (ts.writechunk !== null && !ts.transforming) {
            ts.transforming = true;
            this._transform(ts.writechunk, ts.writeencoding, ts.afterTransform);
          } else {
            ts.needTransform = true;
          }
        };
        Transform.prototype._destroy = function (err, cb) {
          Duplex.prototype._destroy.call(this, err, function (err2) {
            cb(err2);
          });
        };
        function done(stream, er, data) {
          if (er) return stream.emit("error", er);
          if (data != null) stream.push(data);
          if (stream._writableState.length)
            throw new ERR_TRANSFORM_WITH_LENGTH_0();
          if (stream._transformState.transforming)
            throw new ERR_TRANSFORM_ALREADY_TRANSFORMING();
          return stream.push(null);
        }
      },
      { "../errors": 65, "./_stream_duplex": 66, inherits: 94 },
    ],
    70: [
      function (require, module, exports) {
        (function (process, global) {
          (function () {
            "use strict";
            module.exports = Writable;
            function WriteReq(chunk, encoding, cb) {
              this.chunk = chunk;
              this.encoding = encoding;
              this.callback = cb;
              this.next = null;
            }
            function CorkedRequest(state) {
              var _this = this;
              this.next = null;
              this.entry = null;
              this.finish = function () {
                onCorkedFinish(_this, state);
              };
            }
            var Duplex;
            Writable.WritableState = WritableState;
            var internalUtil = { deprecate: require("util-deprecate") };
            var Stream = require("./internal/streams/stream");
            var Buffer = require("buffer").Buffer;
            var OurUint8Array = global.Uint8Array || function () {};
            function _uint8ArrayToBuffer(chunk) {
              return Buffer.from(chunk);
            }
            function _isUint8Array(obj) {
              return Buffer.isBuffer(obj) || obj instanceof OurUint8Array;
            }
            var destroyImpl = require("./internal/streams/destroy");
            var _require = require("./internal/streams/state"),
              getHighWaterMark = _require.getHighWaterMark;
            var _require$codes = require("../errors").codes,
              ERR_INVALID_ARG_TYPE = _require$codes.ERR_INVALID_ARG_TYPE,
              ERR_METHOD_NOT_IMPLEMENTED =
                _require$codes.ERR_METHOD_NOT_IMPLEMENTED,
              ERR_MULTIPLE_CALLBACK = _require$codes.ERR_MULTIPLE_CALLBACK,
              ERR_STREAM_CANNOT_PIPE = _require$codes.ERR_STREAM_CANNOT_PIPE,
              ERR_STREAM_DESTROYED = _require$codes.ERR_STREAM_DESTROYED,
              ERR_STREAM_NULL_VALUES = _require$codes.ERR_STREAM_NULL_VALUES,
              ERR_STREAM_WRITE_AFTER_END =
                _require$codes.ERR_STREAM_WRITE_AFTER_END,
              ERR_UNKNOWN_ENCODING = _require$codes.ERR_UNKNOWN_ENCODING;
            var errorOrDestroy = destroyImpl.errorOrDestroy;
            require("inherits")(Writable, Stream);
            function nop() {}
            function WritableState(options, stream, isDuplex) {
              Duplex = Duplex || require("./_stream_duplex");
              options = options || {};
              if (typeof isDuplex !== "boolean")
                isDuplex = stream instanceof Duplex;
              this.objectMode = !!options.objectMode;
              if (isDuplex)
                this.objectMode =
                  this.objectMode || !!options.writableObjectMode;
              this.highWaterMark = getHighWaterMark(
                this,
                options,
                "writableHighWaterMark",
                isDuplex
              );
              this.finalCalled = false;
              this.needDrain = false;
              this.ending = false;
              this.ended = false;
              this.finished = false;
              this.destroyed = false;
              var noDecode = options.decodeStrings === false;
              this.decodeStrings = !noDecode;
              this.defaultEncoding = options.defaultEncoding || "utf8";
              this.length = 0;
              this.writing = false;
              this.corked = 0;
              this.sync = true;
              this.bufferProcessing = false;
              this.onwrite = function (er) {
                onwrite(stream, er);
              };
              this.writecb = null;
              this.writelen = 0;
              this.bufferedRequest = null;
              this.lastBufferedRequest = null;
              this.pendingcb = 0;
              this.prefinished = false;
              this.errorEmitted = false;
              this.emitClose = options.emitClose !== false;
              this.autoDestroy = !!options.autoDestroy;
              this.bufferedRequestCount = 0;
              this.corkedRequestsFree = new CorkedRequest(this);
            }
            WritableState.prototype.getBuffer = function getBuffer() {
              var current = this.bufferedRequest;
              var out = [];
              while (current) {
                out.push(current);
                current = current.next;
              }
              return out;
            };
            (function () {
              try {
                Object.defineProperty(WritableState.prototype, "buffer", {
                  get: internalUtil.deprecate(
                    function writableStateBufferGetter() {
                      return this.getBuffer();
                    },
                    "_writableState.buffer is deprecated. Use _writableState.getBuffer " +
                      "instead.",
                    "DEP0003"
                  ),
                });
              } catch (_) {}
            })();
            var realHasInstance;
            if (
              typeof Symbol === "function" &&
              Symbol.hasInstance &&
              typeof Function.prototype[Symbol.hasInstance] === "function"
            ) {
              realHasInstance = Function.prototype[Symbol.hasInstance];
              Object.defineProperty(Writable, Symbol.hasInstance, {
                value: function value(object) {
                  if (realHasInstance.call(this, object)) return true;
                  if (this !== Writable) return false;
                  return (
                    object && object._writableState instanceof WritableState
                  );
                },
              });
            } else {
              realHasInstance = function realHasInstance(object) {
                return object instanceof this;
              };
            }
            function Writable(options) {
              Duplex = Duplex || require("./_stream_duplex");
              var isDuplex = this instanceof Duplex;
              if (!isDuplex && !realHasInstance.call(Writable, this))
                return new Writable(options);
              this._writableState = new WritableState(options, this, isDuplex);
              this.writable = true;
              if (options) {
                if (typeof options.write === "function")
                  this._write = options.write;
                if (typeof options.writev === "function")
                  this._writev = options.writev;
                if (typeof options.destroy === "function")
                  this._destroy = options.destroy;
                if (typeof options.final === "function")
                  this._final = options.final;
              }
              Stream.call(this);
            }
            Writable.prototype.pipe = function () {
              errorOrDestroy(this, new ERR_STREAM_CANNOT_PIPE());
            };
            function writeAfterEnd(stream, cb) {
              var er = new ERR_STREAM_WRITE_AFTER_END();
              errorOrDestroy(stream, er);
              process.nextTick(cb, er);
            }
            function validChunk(stream, state, chunk, cb) {
              var er;
              if (chunk === null) {
                er = new ERR_STREAM_NULL_VALUES();
              } else if (typeof chunk !== "string" && !state.objectMode) {
                er = new ERR_INVALID_ARG_TYPE(
                  "chunk",
                  ["string", "Buffer"],
                  chunk
                );
              }
              if (er) {
                errorOrDestroy(stream, er);
                process.nextTick(cb, er);
                return false;
              }
              return true;
            }
            Writable.prototype.write = function (chunk, encoding, cb) {
              var state = this._writableState;
              var ret = false;
              var isBuf = !state.objectMode && _isUint8Array(chunk);
              if (isBuf && !Buffer.isBuffer(chunk)) {
                chunk = _uint8ArrayToBuffer(chunk);
              }
              if (typeof encoding === "function") {
                cb = encoding;
                encoding = null;
              }
              if (isBuf) encoding = "buffer";
              else if (!encoding) encoding = state.defaultEncoding;
              if (typeof cb !== "function") cb = nop;
              if (state.ending) writeAfterEnd(this, cb);
              else if (isBuf || validChunk(this, state, chunk, cb)) {
                state.pendingcb++;
                ret = writeOrBuffer(this, state, isBuf, chunk, encoding, cb);
              }
              return ret;
            };
            Writable.prototype.cork = function () {
              this._writableState.corked++;
            };
            Writable.prototype.uncork = function () {
              var state = this._writableState;
              if (state.corked) {
                state.corked--;
                if (
                  !state.writing &&
                  !state.corked &&
                  !state.bufferProcessing &&
                  state.bufferedRequest
                )
                  clearBuffer(this, state);
              }
            };
            Writable.prototype.setDefaultEncoding = function setDefaultEncoding(
              encoding
            ) {
              if (typeof encoding === "string")
                encoding = encoding.toLowerCase();
              if (
                !(
                  [
                    "hex",
                    "utf8",
                    "utf-8",
                    "ascii",
                    "binary",
                    "base64",
                    "ucs2",
                    "ucs-2",
                    "utf16le",
                    "utf-16le",
                    "raw",
                  ].indexOf((encoding + "").toLowerCase()) > -1
                )
              )
                throw new ERR_UNKNOWN_ENCODING(encoding);
              this._writableState.defaultEncoding = encoding;
              return this;
            };
            Object.defineProperty(Writable.prototype, "writableBuffer", {
              enumerable: false,
              get: function get() {
                return this._writableState && this._writableState.getBuffer();
              },
            });
            function decodeChunk(state, chunk, encoding) {
              if (
                !state.objectMode &&
                state.decodeStrings !== false &&
                typeof chunk === "string"
              ) {
                chunk = Buffer.from(chunk, encoding);
              }
              return chunk;
            }
            Object.defineProperty(Writable.prototype, "writableHighWaterMark", {
              enumerable: false,
              get: function get() {
                return this._writableState.highWaterMark;
              },
            });
            function writeOrBuffer(stream, state, isBuf, chunk, encoding, cb) {
              if (!isBuf) {
                var newChunk = decodeChunk(state, chunk, encoding);
                if (chunk !== newChunk) {
                  isBuf = true;
                  encoding = "buffer";
                  chunk = newChunk;
                }
              }
              var len = state.objectMode ? 1 : chunk.length;
              state.length += len;
              var ret = state.length < state.highWaterMark;
              if (!ret) state.needDrain = true;
              if (state.writing || state.corked) {
                var last = state.lastBufferedRequest;
                state.lastBufferedRequest = {
                  chunk: chunk,
                  encoding: encoding,
                  isBuf: isBuf,
                  callback: cb,
                  next: null,
                };
                if (last) {
                  last.next = state.lastBufferedRequest;
                } else {
                  state.bufferedRequest = state.lastBufferedRequest;
                }
                state.bufferedRequestCount += 1;
              } else {
                doWrite(stream, state, false, len, chunk, encoding, cb);
              }
              return ret;
            }
            function doWrite(stream, state, writev, len, chunk, encoding, cb) {
              state.writelen = len;
              state.writecb = cb;
              state.writing = true;
              state.sync = true;
              if (state.destroyed)
                state.onwrite(new ERR_STREAM_DESTROYED("write"));
              else if (writev) stream._writev(chunk, state.onwrite);
              else stream._write(chunk, encoding, state.onwrite);
              state.sync = false;
            }
            function onwriteError(stream, state, sync, er, cb) {
              --state.pendingcb;
              if (sync) {
                process.nextTick(cb, er);
                process.nextTick(finishMaybe, stream, state);
                stream._writableState.errorEmitted = true;
                errorOrDestroy(stream, er);
              } else {
                cb(er);
                stream._writableState.errorEmitted = true;
                errorOrDestroy(stream, er);
                finishMaybe(stream, state);
              }
            }
            function onwriteStateUpdate(state) {
              state.writing = false;
              state.writecb = null;
              state.length -= state.writelen;
              state.writelen = 0;
            }
            function onwrite(stream, er) {
              var state = stream._writableState;
              var sync = state.sync;
              var cb = state.writecb;
              if (typeof cb !== "function") throw new ERR_MULTIPLE_CALLBACK();
              onwriteStateUpdate(state);
              if (er) onwriteError(stream, state, sync, er, cb);
              else {
                var finished = needFinish(state) || stream.destroyed;
                if (
                  !finished &&
                  !state.corked &&
                  !state.bufferProcessing &&
                  state.bufferedRequest
                ) {
                  clearBuffer(stream, state);
                }
                if (sync) {
                  process.nextTick(afterWrite, stream, state, finished, cb);
                } else {
                  afterWrite(stream, state, finished, cb);
                }
              }
            }
            function afterWrite(stream, state, finished, cb) {
              if (!finished) onwriteDrain(stream, state);
              state.pendingcb--;
              cb();
              finishMaybe(stream, state);
            }
            function onwriteDrain(stream, state) {
              if (state.length === 0 && state.needDrain) {
                state.needDrain = false;
                stream.emit("drain");
              }
            }
            function clearBuffer(stream, state) {
              state.bufferProcessing = true;
              var entry = state.bufferedRequest;
              if (stream._writev && entry && entry.next) {
                var l = state.bufferedRequestCount;
                var buffer = new Array(l);
                var holder = state.corkedRequestsFree;
                holder.entry = entry;
                var count = 0;
                var allBuffers = true;
                while (entry) {
                  buffer[count] = entry;
                  if (!entry.isBuf) allBuffers = false;
                  entry = entry.next;
                  count += 1;
                }
                buffer.allBuffers = allBuffers;
                doWrite(
                  stream,
                  state,
                  true,
                  state.length,
                  buffer,
                  "",
                  holder.finish
                );
                state.pendingcb++;
                state.lastBufferedRequest = null;
                if (holder.next) {
                  state.corkedRequestsFree = holder.next;
                  holder.next = null;
                } else {
                  state.corkedRequestsFree = new CorkedRequest(state);
                }
                state.bufferedRequestCount = 0;
              } else {
                while (entry) {
                  var chunk = entry.chunk;
                  var encoding = entry.encoding;
                  var cb = entry.callback;
                  var len = state.objectMode ? 1 : chunk.length;
                  doWrite(stream, state, false, len, chunk, encoding, cb);
                  entry = entry.next;
                  state.bufferedRequestCount--;
                  if (state.writing) {
                    break;
                  }
                }
                if (entry === null) state.lastBufferedRequest = null;
              }
              state.bufferedRequest = entry;
              state.bufferProcessing = false;
            }
            Writable.prototype._write = function (chunk, encoding, cb) {
              cb(new ERR_METHOD_NOT_IMPLEMENTED("_write()"));
            };
            Writable.prototype._writev = null;
            Writable.prototype.end = function (chunk, encoding, cb) {
              var state = this._writableState;
              if (typeof chunk === "function") {
                cb = chunk;
                chunk = null;
                encoding = null;
              } else if (typeof encoding === "function") {
                cb = encoding;
                encoding = null;
              }
              if (chunk !== null && chunk !== undefined)
                this.write(chunk, encoding);
              if (state.corked) {
                state.corked = 1;
                this.uncork();
              }
              if (!state.ending) endWritable(this, state, cb);
              return this;
            };
            Object.defineProperty(Writable.prototype, "writableLength", {
              enumerable: false,
              get: function get() {
                return this._writableState.length;
              },
            });
            function needFinish(state) {
              return (
                state.ending &&
                state.length === 0 &&
                state.bufferedRequest === null &&
                !state.finished &&
                !state.writing
              );
            }
            function callFinal(stream, state) {
              stream._final(function (err) {
                state.pendingcb--;
                if (err) {
                  errorOrDestroy(stream, err);
                }
                state.prefinished = true;
                stream.emit("prefinish");
                finishMaybe(stream, state);
              });
            }
            function prefinish(stream, state) {
              if (!state.prefinished && !state.finalCalled) {
                if (typeof stream._final === "function" && !state.destroyed) {
                  state.pendingcb++;
                  state.finalCalled = true;
                  process.nextTick(callFinal, stream, state);
                } else {
                  state.prefinished = true;
                  stream.emit("prefinish");
                }
              }
            }
            function finishMaybe(stream, state) {
              var need = needFinish(state);
              if (need) {
                prefinish(stream, state);
                if (state.pendingcb === 0) {
                  state.finished = true;
                  stream.emit("finish");
                  if (state.autoDestroy) {
                    var rState = stream._readableState;
                    if (!rState || (rState.autoDestroy && rState.endEmitted)) {
                      stream.destroy();
                    }
                  }
                }
              }
              return need;
            }
            function endWritable(stream, state, cb) {
              state.ending = true;
              finishMaybe(stream, state);
              if (cb) {
                if (state.finished) process.nextTick(cb);
                else stream.once("finish", cb);
              }
              state.ended = true;
              stream.writable = false;
            }
            function onCorkedFinish(corkReq, state, err) {
              var entry = corkReq.entry;
              corkReq.entry = null;
              while (entry) {
                var cb = entry.callback;
                state.pendingcb--;
                cb(err);
                entry = entry.next;
              }
              state.corkedRequestsFree.next = corkReq;
            }
            Object.defineProperty(Writable.prototype, "destroyed", {
              enumerable: false,
              get: function get() {
                if (this._writableState === undefined) {
                  return false;
                }
                return this._writableState.destroyed;
              },
              set: function set(value) {
                if (!this._writableState) {
                  return;
                }
                this._writableState.destroyed = value;
              },
            });
            Writable.prototype.destroy = destroyImpl.destroy;
            Writable.prototype._undestroy = destroyImpl.undestroy;
            Writable.prototype._destroy = function (err, cb) {
              cb(err);
            };
          }).call(this);
        }).call(
          this,
          require("_process"),
          typeof global !== "undefined"
            ? global
            : typeof self !== "undefined"
            ? self
            : typeof window !== "undefined"
            ? window
            : {}
        );
      },
      {
        "../errors": 65,
        "./_stream_duplex": 66,
        "./internal/streams/destroy": 73,
        "./internal/streams/state": 77,
        "./internal/streams/stream": 78,
        _process: 122,
        buffer: 25,
        inherits: 94,
        "util-deprecate": 157,
      },
    ],
    71: [
      function (require, module, exports) {
        (function (process) {
          (function () {
            "use strict";
            var _Object$setPrototypeO;
            function _defineProperty(obj, key, value) {
              if (key in obj) {
                Object.defineProperty(obj, key, {
                  value: value,
                  enumerable: true,
                  configurable: true,
                  writable: true,
                });
              } else {
                obj[key] = value;
              }
              return obj;
            }
            var finished = require("./end-of-stream");
            var kLastResolve = Symbol("lastResolve");
            var kLastReject = Symbol("lastReject");
            var kError = Symbol("error");
            var kEnded = Symbol("ended");
            var kLastPromise = Symbol("lastPromise");
            var kHandlePromise = Symbol("handlePromise");
            var kStream = Symbol("stream");
            function createIterResult(value, done) {
              return { value: value, done: done };
            }
            function readAndResolve(iter) {
              var resolve = iter[kLastResolve];
              if (resolve !== null) {
                var data = iter[kStream].read();
                if (data !== null) {
                  iter[kLastPromise] = null;
                  iter[kLastResolve] = null;
                  iter[kLastReject] = null;
                  resolve(createIterResult(data, false));
                }
              }
            }
            function onReadable(iter) {
              process.nextTick(readAndResolve, iter);
            }
            function wrapForNext(lastPromise, iter) {
              return function (resolve, reject) {
                lastPromise.then(function () {
                  if (iter[kEnded]) {
                    resolve(createIterResult(undefined, true));
                    return;
                  }
                  iter[kHandlePromise](resolve, reject);
                }, reject);
              };
            }
            var AsyncIteratorPrototype = Object.getPrototypeOf(function () {});
            var ReadableStreamAsyncIteratorPrototype = Object.setPrototypeOf(
              ((_Object$setPrototypeO = {
                get stream() {
                  return this[kStream];
                },
                next: function next() {
                  var _this = this;
                  var error = this[kError];
                  if (error !== null) {
                    return Promise.reject(error);
                  }
                  if (this[kEnded]) {
                    return Promise.resolve(createIterResult(undefined, true));
                  }
                  if (this[kStream].destroyed) {
                    return new Promise(function (resolve, reject) {
                      process.nextTick(function () {
                        if (_this[kError]) {
                          reject(_this[kError]);
                        } else {
                          resolve(createIterResult(undefined, true));
                        }
                      });
                    });
                  }
                  var lastPromise = this[kLastPromise];
                  var promise;
                  if (lastPromise) {
                    promise = new Promise(wrapForNext(lastPromise, this));
                  } else {
                    var data = this[kStream].read();
                    if (data !== null) {
                      return Promise.resolve(createIterResult(data, false));
                    }
                    promise = new Promise(this[kHandlePromise]);
                  }
                  this[kLastPromise] = promise;
                  return promise;
                },
              }),
              _defineProperty(
                _Object$setPrototypeO,
                Symbol.asyncIterator,
                function () {
                  return this;
                }
              ),
              _defineProperty(
                _Object$setPrototypeO,
                "return",
                function _return() {
                  var _this2 = this;
                  return new Promise(function (resolve, reject) {
                    _this2[kStream].destroy(null, function (err) {
                      if (err) {
                        reject(err);
                        return;
                      }
                      resolve(createIterResult(undefined, true));
                    });
                  });
                }
              ),
              _Object$setPrototypeO),
              AsyncIteratorPrototype
            );
            var createReadableStreamAsyncIterator =
              function createReadableStreamAsyncIterator(stream) {
                var _Object$create;
                var iterator = Object.create(
                  ReadableStreamAsyncIteratorPrototype,
                  ((_Object$create = {}),
                  _defineProperty(_Object$create, kStream, {
                    value: stream,
                    writable: true,
                  }),
                  _defineProperty(_Object$create, kLastResolve, {
                    value: null,
                    writable: true,
                  }),
                  _defineProperty(_Object$create, kLastReject, {
                    value: null,
                    writable: true,
                  }),
                  _defineProperty(_Object$create, kError, {
                    value: null,
                    writable: true,
                  }),
                  _defineProperty(_Object$create, kEnded, {
                    value: stream._readableState.endEmitted,
                    writable: true,
                  }),
                  _defineProperty(_Object$create, kHandlePromise, {
                    value: function value(resolve, reject) {
                      var data = iterator[kStream].read();
                      if (data) {
                        iterator[kLastPromise] = null;
                        iterator[kLastResolve] = null;
                        iterator[kLastReject] = null;
                        resolve(createIterResult(data, false));
                      } else {
                        iterator[kLastResolve] = resolve;
                        iterator[kLastReject] = reject;
                      }
                    },
                    writable: true,
                  }),
                  _Object$create)
                );
                iterator[kLastPromise] = null;
                finished(stream, function (err) {
                  if (err && err.code !== "ERR_STREAM_PREMATURE_CLOSE") {
                    var reject = iterator[kLastReject];
                    if (reject !== null) {
                      iterator[kLastPromise] = null;
                      iterator[kLastResolve] = null;
                      iterator[kLastReject] = null;
                      reject(err);
                    }
                    iterator[kError] = err;
                    return;
                  }
                  var resolve = iterator[kLastResolve];
                  if (resolve !== null) {
                    iterator[kLastPromise] = null;
                    iterator[kLastResolve] = null;
                    iterator[kLastReject] = null;
                    resolve(createIterResult(undefined, true));
                  }
                  iterator[kEnded] = true;
                });
                stream.on("readable", onReadable.bind(null, iterator));
                return iterator;
              };
            module.exports = createReadableStreamAsyncIterator;
          }).call(this);
        }).call(this, require("_process"));
      },
      { "./end-of-stream": 74, _process: 122 },
    ],
    72: [
      function (require, module, exports) {
        "use strict";
        function ownKeys(object, enumerableOnly) {
          var keys = Object.keys(object);
          if (Object.getOwnPropertySymbols) {
            var symbols = Object.getOwnPropertySymbols(object);
            if (enumerableOnly)
              symbols = symbols.filter(function (sym) {
                return Object.getOwnPropertyDescriptor(object, sym).enumerable;
              });
            keys.push.apply(keys, symbols);
          }
          return keys;
        }
        function _objectSpread(target) {
          for (var i = 1; i < arguments.length; i++) {
            var source = arguments[i] != null ? arguments[i] : {};
            if (i % 2) {
              ownKeys(Object(source), true).forEach(function (key) {
                _defineProperty(target, key, source[key]);
              });
            } else if (Object.getOwnPropertyDescriptors) {
              Object.defineProperties(
                target,
                Object.getOwnPropertyDescriptors(source)
              );
            } else {
              ownKeys(Object(source)).forEach(function (key) {
                Object.defineProperty(
                  target,
                  key,
                  Object.getOwnPropertyDescriptor(source, key)
                );
              });
            }
          }
          return target;
        }
        function _defineProperty(obj, key, value) {
          if (key in obj) {
            Object.defineProperty(obj, key, {
              value: value,
              enumerable: true,
              configurable: true,
              writable: true,
            });
          } else {
            obj[key] = value;
          }
          return obj;
        }
        function _classCallCheck(instance, Constructor) {
          if (!(instance instanceof Constructor)) {
            throw new TypeError("Cannot call a class as a function");
          }
        }
        function _defineProperties(target, props) {
          for (var i = 0; i < props.length; i++) {
            var descriptor = props[i];
            descriptor.enumerable = descriptor.enumerable || false;
            descriptor.configurable = true;
            if ("value" in descriptor) descriptor.writable = true;
            Object.defineProperty(target, descriptor.key, descriptor);
          }
        }
        function _createClass(Constructor, protoProps, staticProps) {
          if (protoProps) _defineProperties(Constructor.prototype, protoProps);
          if (staticProps) _defineProperties(Constructor, staticProps);
          return Constructor;
        }
        var _require = require("buffer"),
          Buffer = _require.Buffer;
        var _require2 = require("util"),
          inspect = _require2.inspect;
        var custom = (inspect && inspect.custom) || "inspect";
        function copyBuffer(src, target, offset) {
          Buffer.prototype.copy.call(src, target, offset);
        }
        module.exports = (function () {
          function BufferList() {
            _classCallCheck(this, BufferList);
            this.head = null;
            this.tail = null;
            this.length = 0;
          }
          _createClass(BufferList, [
            {
              key: "push",
              value: function push(v) {
                var entry = { data: v, next: null };
                if (this.length > 0) this.tail.next = entry;
                else this.head = entry;
                this.tail = entry;
                ++this.length;
              },
            },
            {
              key: "unshift",
              value: function unshift(v) {
                var entry = { data: v, next: this.head };
                if (this.length === 0) this.tail = entry;
                this.head = entry;
                ++this.length;
              },
            },
            {
              key: "shift",
              value: function shift() {
                if (this.length === 0) return;
                var ret = this.head.data;
                if (this.length === 1) this.head = this.tail = null;
                else this.head = this.head.next;
                --this.length;
                return ret;
              },
            },
            {
              key: "clear",
              value: function clear() {
                this.head = this.tail = null;
                this.length = 0;
              },
            },
            {
              key: "join",
              value: function join(s) {
                if (this.length === 0) return "";
                var p = this.head;
                var ret = "" + p.data;
                while ((p = p.next)) {
                  ret += s + p.data;
                }
                return ret;
              },
            },
            {
              key: "concat",
              value: function concat(n) {
                if (this.length === 0) return Buffer.alloc(0);
                var ret = Buffer.allocUnsafe(n >>> 0);
                var p = this.head;
                var i = 0;
                while (p) {
                  copyBuffer(p.data, ret, i);
                  i += p.data.length;
                  p = p.next;
                }
                return ret;
              },
            },
            {
              key: "consume",
              value: function consume(n, hasStrings) {
                var ret;
                if (n < this.head.data.length) {
                  ret = this.head.data.slice(0, n);
                  this.head.data = this.head.data.slice(n);
                } else if (n === this.head.data.length) {
                  ret = this.shift();
                } else {
                  ret = hasStrings ? this._getString(n) : this._getBuffer(n);
                }
                return ret;
              },
            },
            {
              key: "first",
              value: function first() {
                return this.head.data;
              },
            },
            {
              key: "_getString",
              value: function _getString(n) {
                var p = this.head;
                var c = 1;
                var ret = p.data;
                n -= ret.length;
                while ((p = p.next)) {
                  var str = p.data;
                  var nb = n > str.length ? str.length : n;
                  if (nb === str.length) ret += str;
                  else ret += str.slice(0, n);
                  n -= nb;
                  if (n === 0) {
                    if (nb === str.length) {
                      ++c;
                      if (p.next) this.head = p.next;
                      else this.head = this.tail = null;
                    } else {
                      this.head = p;
                      p.data = str.slice(nb);
                    }
                    break;
                  }
                  ++c;
                }
                this.length -= c;
                return ret;
              },
            },
            {
              key: "_getBuffer",
              value: function _getBuffer(n) {
                var ret = Buffer.allocUnsafe(n);
                var p = this.head;
                var c = 1;
                p.data.copy(ret);
                n -= p.data.length;
                while ((p = p.next)) {
                  var buf = p.data;
                  var nb = n > buf.length ? buf.length : n;
                  buf.copy(ret, ret.length - n, 0, nb);
                  n -= nb;
                  if (n === 0) {
                    if (nb === buf.length) {
                      ++c;
                      if (p.next) this.head = p.next;
                      else this.head = this.tail = null;
                    } else {
                      this.head = p;
                      p.data = buf.slice(nb);
                    }
                    break;
                  }
                  ++c;
                }
                this.length -= c;
                return ret;
              },
            },
            {
              key: custom,
              value: function value(_, options) {
                return inspect(
                  this,
                  _objectSpread({}, options, { depth: 0, customInspect: false })
                );
              },
            },
          ]);
          return BufferList;
        })();
      },
      { buffer: 25, util: 24 },
    ],
    73: [
      function (require, module, exports) {
        (function (process) {
          (function () {
            "use strict";
            function destroy(err, cb) {
              var _this = this;
              var readableDestroyed =
                this._readableState && this._readableState.destroyed;
              var writableDestroyed =
                this._writableState && this._writableState.destroyed;
              if (readableDestroyed || writableDestroyed) {
                if (cb) {
                  cb(err);
                } else if (err) {
                  if (!this._writableState) {
                    process.nextTick(emitErrorNT, this, err);
                  } else if (!this._writableState.errorEmitted) {
                    this._writableState.errorEmitted = true;
                    process.nextTick(emitErrorNT, this, err);
                  }
                }
                return this;
              }
              if (this._readableState) {
                this._readableState.destroyed = true;
              }
              if (this._writableState) {
                this._writableState.destroyed = true;
              }
              this._destroy(err || null, function (err) {
                if (!cb && err) {
                  if (!_this._writableState) {
                    process.nextTick(emitErrorAndCloseNT, _this, err);
                  } else if (!_this._writableState.errorEmitted) {
                    _this._writableState.errorEmitted = true;
                    process.nextTick(emitErrorAndCloseNT, _this, err);
                  } else {
                    process.nextTick(emitCloseNT, _this);
                  }
                } else if (cb) {
                  process.nextTick(emitCloseNT, _this);
                  cb(err);
                } else {
                  process.nextTick(emitCloseNT, _this);
                }
              });
              return this;
            }
            function emitErrorAndCloseNT(self, err) {
              emitErrorNT(self, err);
              emitCloseNT(self);
            }
            function emitCloseNT(self) {
              if (self._writableState && !self._writableState.emitClose) return;
              if (self._readableState && !self._readableState.emitClose) return;
              self.emit("close");
            }
            function undestroy() {
              if (this._readableState) {
                this._readableState.destroyed = false;
                this._readableState.reading = false;
                this._readableState.ended = false;
                this._readableState.endEmitted = false;
              }
              if (this._writableState) {
                this._writableState.destroyed = false;
                this._writableState.ended = false;
                this._writableState.ending = false;
                this._writableState.finalCalled = false;
                this._writableState.prefinished = false;
                this._writableState.finished = false;
                this._writableState.errorEmitted = false;
              }
            }
            function emitErrorNT(self, err) {
              self.emit("error", err);
            }
            function errorOrDestroy(stream, err) {
              var rState = stream._readableState;
              var wState = stream._writableState;
              if (
                (rState && rState.autoDestroy) ||
                (wState && wState.autoDestroy)
              )
                stream.destroy(err);
              else stream.emit("error", err);
            }
            module.exports = {
              destroy: destroy,
              undestroy: undestroy,
              errorOrDestroy: errorOrDestroy,
            };
          }).call(this);
        }).call(this, require("_process"));
      },
      { _process: 122 },
    ],
    74: [
      function (require, module, exports) {
        "use strict";
        var ERR_STREAM_PREMATURE_CLOSE =
          require("../../../errors").codes.ERR_STREAM_PREMATURE_CLOSE;
        function once(callback) {
          var called = false;
          return function () {
            if (called) return;
            called = true;
            for (
              var _len = arguments.length, args = new Array(_len), _key = 0;
              _key < _len;
              _key++
            ) {
              args[_key] = arguments[_key];
            }
            callback.apply(this, args);
          };
        }
        function noop() {}
        function isRequest(stream) {
          return stream.setHeader && typeof stream.abort === "function";
        }
        function eos(stream, opts, callback) {
          if (typeof opts === "function") return eos(stream, null, opts);
          if (!opts) opts = {};
          callback = once(callback || noop);
          var readable =
            opts.readable || (opts.readable !== false && stream.readable);
          var writable =
            opts.writable || (opts.writable !== false && stream.writable);
          var onlegacyfinish = function onlegacyfinish() {
            if (!stream.writable) onfinish();
          };
          var writableEnded =
            stream._writableState && stream._writableState.finished;
          var onfinish = function onfinish() {
            writable = false;
            writableEnded = true;
            if (!readable) callback.call(stream);
          };
          var readableEnded =
            stream._readableState && stream._readableState.endEmitted;
          var onend = function onend() {
            readable = false;
            readableEnded = true;
            if (!writable) callback.call(stream);
          };
          var onerror = function onerror(err) {
            callback.call(stream, err);
          };
          var onclose = function onclose() {
            var err;
            if (readable && !readableEnded) {
              if (!stream._readableState || !stream._readableState.ended)
                err = new ERR_STREAM_PREMATURE_CLOSE();
              return callback.call(stream, err);
            }
            if (writable && !writableEnded) {
              if (!stream._writableState || !stream._writableState.ended)
                err = new ERR_STREAM_PREMATURE_CLOSE();
              return callback.call(stream, err);
            }
          };
          var onrequest = function onrequest() {
            stream.req.on("finish", onfinish);
          };
          if (isRequest(stream)) {
            stream.on("complete", onfinish);
            stream.on("abort", onclose);
            if (stream.req) onrequest();
            else stream.on("request", onrequest);
          } else if (writable && !stream._writableState) {
            stream.on("end", onlegacyfinish);
            stream.on("close", onlegacyfinish);
          }
          stream.on("end", onend);
          stream.on("finish", onfinish);
          if (opts.error !== false) stream.on("error", onerror);
          stream.on("close", onclose);
          return function () {
            stream.removeListener("complete", onfinish);
            stream.removeListener("abort", onclose);
            stream.removeListener("request", onrequest);
            if (stream.req) stream.req.removeListener("finish", onfinish);
            stream.removeListener("end", onlegacyfinish);
            stream.removeListener("close", onlegacyfinish);
            stream.removeListener("finish", onfinish);
            stream.removeListener("end", onend);
            stream.removeListener("error", onerror);
            stream.removeListener("close", onclose);
          };
        }
        module.exports = eos;
      },
      { "../../../errors": 65 },
    ],
    75: [
      function (require, module, exports) {
        module.exports = function () {
          throw new Error("Readable.from is not available in the browser");
        };
      },
      {},
    ],
    76: [
      function (require, module, exports) {
        "use strict";
        var eos;
        function once(callback) {
          var called = false;
          return function () {
            if (called) return;
            called = true;
            callback.apply(void 0, arguments);
          };
        }
        var _require$codes = require("../../../errors").codes,
          ERR_MISSING_ARGS = _require$codes.ERR_MISSING_ARGS,
          ERR_STREAM_DESTROYED = _require$codes.ERR_STREAM_DESTROYED;
        function noop(err) {
          if (err) throw err;
        }
        function isRequest(stream) {
          return stream.setHeader && typeof stream.abort === "function";
        }
        function destroyer(stream, reading, writing, callback) {
          callback = once(callback);
          var closed = false;
          stream.on("close", function () {
            closed = true;
          });
          if (eos === undefined) eos = require("./end-of-stream");
          eos(stream, { readable: reading, writable: writing }, function (err) {
            if (err) return callback(err);
            closed = true;
            callback();
          });
          var destroyed = false;
          return function (err) {
            if (closed) return;
            if (destroyed) return;
            destroyed = true;
            if (isRequest(stream)) return stream.abort();
            if (typeof stream.destroy === "function") return stream.destroy();
            callback(err || new ERR_STREAM_DESTROYED("pipe"));
          };
        }
        function call(fn) {
          fn();
        }
        function pipe(from, to) {
          return from.pipe(to);
        }
        function popCallback(streams) {
          if (!streams.length) return noop;
          if (typeof streams[streams.length - 1] !== "function") return noop;
          return streams.pop();
        }
        function pipeline() {
          for (
            var _len = arguments.length, streams = new Array(_len), _key = 0;
            _key < _len;
            _key++
          ) {
            streams[_key] = arguments[_key];
          }
          var callback = popCallback(streams);
          if (Array.isArray(streams[0])) streams = streams[0];
          if (streams.length < 2) {
            throw new ERR_MISSING_ARGS("streams");
          }
          var error;
          var destroys = streams.map(function (stream, i) {
            var reading = i < streams.length - 1;
            var writing = i > 0;
            return destroyer(stream, reading, writing, function (err) {
              if (!error) error = err;
              if (err) destroys.forEach(call);
              if (reading) return;
              destroys.forEach(call);
              callback(error);
            });
          });
          return streams.reduce(pipe);
        }
        module.exports = pipeline;
      },
      { "../../../errors": 65, "./end-of-stream": 74 },
    ],
    77: [
      function (require, module, exports) {
        "use strict";
        var ERR_INVALID_OPT_VALUE =
          require("../../../errors").codes.ERR_INVALID_OPT_VALUE;
        function highWaterMarkFrom(options, isDuplex, duplexKey) {
          return options.highWaterMark != null
            ? options.highWaterMark
            : isDuplex
            ? options[duplexKey]
            : null;
        }
        function getHighWaterMark(state, options, duplexKey, isDuplex) {
          var hwm = highWaterMarkFrom(options, isDuplex, duplexKey);
          if (hwm != null) {
            if (!(isFinite(hwm) && Math.floor(hwm) === hwm) || hwm < 0) {
              var name = isDuplex ? duplexKey : "highWaterMark";
              throw new ERR_INVALID_OPT_VALUE(name, hwm);
            }
            return Math.floor(hwm);
          }
          return state.objectMode ? 16 : 16 * 1024;
        }
        module.exports = { getHighWaterMark: getHighWaterMark };
      },
      { "../../../errors": 65 },
    ],
    78: [
      function (require, module, exports) {
        module.exports = require("events").EventEmitter;
      },
      { events: 63 },
    ],
    79: [
      function (require, module, exports) {
        exports = module.exports = require("./lib/_stream_readable.js");
        exports.Stream = exports;
        exports.Readable = exports;
        exports.Writable = require("./lib/_stream_writable.js");
        exports.Duplex = require("./lib/_stream_duplex.js");
        exports.Transform = require("./lib/_stream_transform.js");
        exports.PassThrough = require("./lib/_stream_passthrough.js");
        exports.finished = require("./lib/internal/streams/end-of-stream.js");
        exports.pipeline = require("./lib/internal/streams/pipeline.js");
      },
      {
        "./lib/_stream_duplex.js": 66,
        "./lib/_stream_passthrough.js": 67,
        "./lib/_stream_readable.js": 68,
        "./lib/_stream_transform.js": 69,
        "./lib/_stream_writable.js": 70,
        "./lib/internal/streams/end-of-stream.js": 74,
        "./lib/internal/streams/pipeline.js": 76,
      },
    ],
    80: [
      function (require, module, exports) {
        var hash = exports;
        hash.utils = require("./hash/utils");
        hash.common = require("./hash/common");
        hash.sha = require("./hash/sha");
        hash.ripemd = require("./hash/ripemd");
        hash.hmac = require("./hash/hmac");
        hash.sha1 = hash.sha.sha1;
        hash.sha256 = hash.sha.sha256;
        hash.sha224 = hash.sha.sha224;
        hash.sha384 = hash.sha.sha384;
        hash.sha512 = hash.sha.sha512;
        hash.ripemd160 = hash.ripemd.ripemd160;
      },
      {
        "./hash/common": 81,
        "./hash/hmac": 82,
        "./hash/ripemd": 83,
        "./hash/sha": 84,
        "./hash/utils": 91,
      },
    ],
    81: [
      function (require, module, exports) {
        "use strict";
        var utils = require("./utils");
        var assert = require("minimalistic-assert");
        function BlockHash() {
          this.pending = null;
          this.pendingTotal = 0;
          this.blockSize = this.constructor.blockSize;
          this.outSize = this.constructor.outSize;
          this.hmacStrength = this.constructor.hmacStrength;
          this.padLength = this.constructor.padLength / 8;
          this.endian = "big";
          this._delta8 = this.blockSize / 8;
          this._delta32 = this.blockSize / 32;
        }
        exports.BlockHash = BlockHash;
        BlockHash.prototype.update = function update(msg, enc) {
          msg = utils.toArray(msg, enc);
          if (!this.pending) this.pending = msg;
          else this.pending = this.pending.concat(msg);
          this.pendingTotal += msg.length;
          if (this.pending.length >= this._delta8) {
            msg = this.pending;
            var r = msg.length % this._delta8;
            this.pending = msg.slice(msg.length - r, msg.length);
            if (this.pending.length === 0) this.pending = null;
            msg = utils.join32(msg, 0, msg.length - r, this.endian);
            for (var i = 0; i < msg.length; i += this._delta32)
              this._update(msg, i, i + this._delta32);
          }
          return this;
        };
        BlockHash.prototype.digest = function digest(enc) {
          this.update(this._pad());
          assert(this.pending === null);
          return this._digest(enc);
        };
        BlockHash.prototype._pad = function pad() {
          var len = this.pendingTotal;
          var bytes = this._delta8;
          var k = bytes - ((len + this.padLength) % bytes);
          var res = new Array(k + this.padLength);
          res[0] = 128;
          for (var i = 1; i < k; i++) res[i] = 0;
          len <<= 3;
          if (this.endian === "big") {
            for (var t = 8; t < this.padLength; t++) res[i++] = 0;
            res[i++] = 0;
            res[i++] = 0;
            res[i++] = 0;
            res[i++] = 0;
            res[i++] = (len >>> 24) & 255;
            res[i++] = (len >>> 16) & 255;
            res[i++] = (len >>> 8) & 255;
            res[i++] = len & 255;
          } else {
            res[i++] = len & 255;
            res[i++] = (len >>> 8) & 255;
            res[i++] = (len >>> 16) & 255;
            res[i++] = (len >>> 24) & 255;
            res[i++] = 0;
            res[i++] = 0;
            res[i++] = 0;
            res[i++] = 0;
            for (t = 8; t < this.padLength; t++) res[i++] = 0;
          }
          return res;
        };
      },
      { "./utils": 91, "minimalistic-assert": 119 },
    ],
    82: [
      function (require, module, exports) {
        "use strict";
        var utils = require("./utils");
        var assert = require("minimalistic-assert");
        function Hmac(hash, key, enc) {
          if (!(this instanceof Hmac)) return new Hmac(hash, key, enc);
          this.Hash = hash;
          this.blockSize = hash.blockSize / 8;
          this.outSize = hash.outSize / 8;
          this.inner = null;
          this.outer = null;
          this._init(utils.toArray(key, enc));
        }
        module.exports = Hmac;
        Hmac.prototype._init = function init(key) {
          if (key.length > this.blockSize)
            key = new this.Hash().update(key).digest();
          assert(key.length <= this.blockSize);
          for (var i = key.length; i < this.blockSize; i++) key.push(0);
          for (i = 0; i < key.length; i++) key[i] ^= 54;
          this.inner = new this.Hash().update(key);
          for (i = 0; i < key.length; i++) key[i] ^= 106;
          this.outer = new this.Hash().update(key);
        };
        Hmac.prototype.update = function update(msg, enc) {
          this.inner.update(msg, enc);
          return this;
        };
        Hmac.prototype.digest = function digest(enc) {
          this.outer.update(this.inner.digest());
          return this.outer.digest(enc);
        };
      },
      { "./utils": 91, "minimalistic-assert": 119 },
    ],
    83: [
      function (require, module, exports) {
        "use strict";
        var utils = require("./utils");
        var common = require("./common");
        var rotl32 = utils.rotl32;
        var sum32 = utils.sum32;
        var sum32_3 = utils.sum32_3;
        var sum32_4 = utils.sum32_4;
        var BlockHash = common.BlockHash;
        function RIPEMD160() {
          if (!(this instanceof RIPEMD160)) return new RIPEMD160();
          BlockHash.call(this);
          this.h = [1732584193, 4023233417, 2562383102, 271733878, 3285377520];
          this.endian = "little";
        }
        utils.inherits(RIPEMD160, BlockHash);
        exports.ripemd160 = RIPEMD160;
        RIPEMD160.blockSize = 512;
        RIPEMD160.outSize = 160;
        RIPEMD160.hmacStrength = 192;
        RIPEMD160.padLength = 64;
        RIPEMD160.prototype._update = function update(msg, start) {
          var A = this.h[0];
          var B = this.h[1];
          var C = this.h[2];
          var D = this.h[3];
          var E = this.h[4];
          var Ah = A;
          var Bh = B;
          var Ch = C;
          var Dh = D;
          var Eh = E;
          for (var j = 0; j < 80; j++) {
            var T = sum32(
              rotl32(sum32_4(A, f(j, B, C, D), msg[r[j] + start], K(j)), s[j]),
              E
            );
            A = E;
            E = D;
            D = rotl32(C, 10);
            C = B;
            B = T;
            T = sum32(
              rotl32(
                sum32_4(Ah, f(79 - j, Bh, Ch, Dh), msg[rh[j] + start], Kh(j)),
                sh[j]
              ),
              Eh
            );
            Ah = Eh;
            Eh = Dh;
            Dh = rotl32(Ch, 10);
            Ch = Bh;
            Bh = T;
          }
          T = sum32_3(this.h[1], C, Dh);
          this.h[1] = sum32_3(this.h[2], D, Eh);
          this.h[2] = sum32_3(this.h[3], E, Ah);
          this.h[3] = sum32_3(this.h[4], A, Bh);
          this.h[4] = sum32_3(this.h[0], B, Ch);
          this.h[0] = T;
        };
        RIPEMD160.prototype._digest = function digest(enc) {
          if (enc === "hex") return utils.toHex32(this.h, "little");
          else return utils.split32(this.h, "little");
        };
        function f(j, x, y, z) {
          if (j <= 15) return x ^ y ^ z;
          else if (j <= 31) return (x & y) | (~x & z);
          else if (j <= 47) return (x | ~y) ^ z;
          else if (j <= 63) return (x & z) | (y & ~z);
          else return x ^ (y | ~z);
        }
        function K(j) {
          if (j <= 15) return 0;
          else if (j <= 31) return 1518500249;
          else if (j <= 47) return 1859775393;
          else if (j <= 63) return 2400959708;
          else return 2840853838;
        }
        function Kh(j) {
          if (j <= 15) return 1352829926;
          else if (j <= 31) return 1548603684;
          else if (j <= 47) return 1836072691;
          else if (j <= 63) return 2053994217;
          else return 0;
        }
        var r = [
          0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 7, 4, 13, 1, 10,
          6, 15, 3, 12, 0, 9, 5, 2, 14, 11, 8, 3, 10, 14, 4, 9, 15, 8, 1, 2, 7,
          0, 6, 13, 11, 5, 12, 1, 9, 11, 10, 0, 8, 12, 4, 13, 3, 7, 15, 14, 5,
          6, 2, 4, 0, 5, 9, 7, 12, 2, 10, 14, 1, 3, 8, 11, 6, 15, 13,
        ];
        var rh = [
          5, 14, 7, 0, 9, 2, 11, 4, 13, 6, 15, 8, 1, 10, 3, 12, 6, 11, 3, 7, 0,
          13, 5, 10, 14, 15, 8, 12, 4, 9, 1, 2, 15, 5, 1, 3, 7, 14, 6, 9, 11, 8,
          12, 2, 10, 0, 4, 13, 8, 6, 4, 1, 3, 11, 15, 0, 5, 12, 2, 13, 9, 7, 10,
          14, 12, 15, 10, 4, 1, 5, 8, 7, 6, 2, 13, 14, 0, 3, 9, 11,
        ];
        var s = [
          11, 14, 15, 12, 5, 8, 7, 9, 11, 13, 14, 15, 6, 7, 9, 8, 7, 6, 8, 13,
          11, 9, 7, 15, 7, 12, 15, 9, 11, 7, 13, 12, 11, 13, 6, 7, 14, 9, 13,
          15, 14, 8, 13, 6, 5, 12, 7, 5, 11, 12, 14, 15, 14, 15, 9, 8, 9, 14, 5,
          6, 8, 6, 5, 12, 9, 15, 5, 11, 6, 8, 13, 12, 5, 12, 13, 14, 11, 8, 5,
          6,
        ];
        var sh = [
          8, 9, 9, 11, 13, 15, 15, 5, 7, 7, 8, 11, 14, 14, 12, 6, 9, 13, 15, 7,
          12, 8, 9, 11, 7, 7, 12, 7, 6, 15, 13, 11, 9, 7, 15, 11, 8, 6, 6, 14,
          12, 13, 5, 14, 13, 13, 7, 5, 15, 5, 8, 11, 14, 14, 6, 14, 6, 9, 12, 9,
          12, 5, 15, 8, 8, 5, 12, 9, 12, 5, 14, 6, 8, 13, 6, 5, 15, 13, 11, 11,
        ];
      },
      { "./common": 81, "./utils": 91 },
    ],
    84: [
      function (require, module, exports) {
        "use strict";
        exports.sha1 = require("./sha/1");
        exports.sha224 = require("./sha/224");
        exports.sha256 = require("./sha/256");
        exports.sha384 = require("./sha/384");
        exports.sha512 = require("./sha/512");
      },
      {
        "./sha/1": 85,
        "./sha/224": 86,
        "./sha/256": 87,
        "./sha/384": 88,
        "./sha/512": 89,
      },
    ],
    85: [
      function (require, module, exports) {
        "use strict";
        var utils = require("../utils");
        var common = require("../common");
        var shaCommon = require("./common");
        var rotl32 = utils.rotl32;
        var sum32 = utils.sum32;
        var sum32_5 = utils.sum32_5;
        var ft_1 = shaCommon.ft_1;
        var BlockHash = common.BlockHash;
        var sha1_K = [1518500249, 1859775393, 2400959708, 3395469782];
        function SHA1() {
          if (!(this instanceof SHA1)) return new SHA1();
          BlockHash.call(this);
          this.h = [1732584193, 4023233417, 2562383102, 271733878, 3285377520];
          this.W = new Array(80);
        }
        utils.inherits(SHA1, BlockHash);
        module.exports = SHA1;
        SHA1.blockSize = 512;
        SHA1.outSize = 160;
        SHA1.hmacStrength = 80;
        SHA1.padLength = 64;
        SHA1.prototype._update = function _update(msg, start) {
          var W = this.W;
          for (var i = 0; i < 16; i++) W[i] = msg[start + i];
          for (; i < W.length; i++)
            W[i] = rotl32(W[i - 3] ^ W[i - 8] ^ W[i - 14] ^ W[i - 16], 1);
          var a = this.h[0];
          var b = this.h[1];
          var c = this.h[2];
          var d = this.h[3];
          var e = this.h[4];
          for (i = 0; i < W.length; i++) {
            var s = ~~(i / 20);
            var t = sum32_5(rotl32(a, 5), ft_1(s, b, c, d), e, W[i], sha1_K[s]);
            e = d;
            d = c;
            c = rotl32(b, 30);
            b = a;
            a = t;
          }
          this.h[0] = sum32(this.h[0], a);
          this.h[1] = sum32(this.h[1], b);
          this.h[2] = sum32(this.h[2], c);
          this.h[3] = sum32(this.h[3], d);
          this.h[4] = sum32(this.h[4], e);
        };
        SHA1.prototype._digest = function digest(enc) {
          if (enc === "hex") return utils.toHex32(this.h, "big");
          else return utils.split32(this.h, "big");
        };
      },
      { "../common": 81, "../utils": 91, "./common": 90 },
    ],
    86: [
      function (require, module, exports) {
        "use strict";
        var utils = require("../utils");
        var SHA256 = require("./256");
        function SHA224() {
          if (!(this instanceof SHA224)) return new SHA224();
          SHA256.call(this);
          this.h = [
            3238371032, 914150663, 812702999, 4144912697, 4290775857,
            1750603025, 1694076839, 3204075428,
          ];
        }
        utils.inherits(SHA224, SHA256);
        module.exports = SHA224;
        SHA224.blockSize = 512;
        SHA224.outSize = 224;
        SHA224.hmacStrength = 192;
        SHA224.padLength = 64;
        SHA224.prototype._digest = function digest(enc) {
          if (enc === "hex") return utils.toHex32(this.h.slice(0, 7), "big");
          else return utils.split32(this.h.slice(0, 7), "big");
        };
      },
      { "../utils": 91, "./256": 87 },
    ],
    87: [
      function (require, module, exports) {
        "use strict";
        var utils = require("../utils");
        var common = require("../common");
        var shaCommon = require("./common");
        var assert = require("minimalistic-assert");
        var sum32 = utils.sum32;
        var sum32_4 = utils.sum32_4;
        var sum32_5 = utils.sum32_5;
        var ch32 = shaCommon.ch32;
        var maj32 = shaCommon.maj32;
        var s0_256 = shaCommon.s0_256;
        var s1_256 = shaCommon.s1_256;
        var g0_256 = shaCommon.g0_256;
        var g1_256 = shaCommon.g1_256;
        var BlockHash = common.BlockHash;
        var sha256_K = [
          1116352408, 1899447441, 3049323471, 3921009573, 961987163, 1508970993,
          2453635748, 2870763221, 3624381080, 310598401, 607225278, 1426881987,
          1925078388, 2162078206, 2614888103, 3248222580, 3835390401,
          4022224774, 264347078, 604807628, 770255983, 1249150122, 1555081692,
          1996064986, 2554220882, 2821834349, 2952996808, 3210313671,
          3336571891, 3584528711, 113926993, 338241895, 666307205, 773529912,
          1294757372, 1396182291, 1695183700, 1986661051, 2177026350,
          2456956037, 2730485921, 2820302411, 3259730800, 3345764771,
          3516065817, 3600352804, 4094571909, 275423344, 430227734, 506948616,
          659060556, 883997877, 958139571, 1322822218, 1537002063, 1747873779,
          1955562222, 2024104815, 2227730452, 2361852424, 2428436474,
          2756734187, 3204031479, 3329325298,
        ];
        function SHA256() {
          if (!(this instanceof SHA256)) return new SHA256();
          BlockHash.call(this);
          this.h = [
            1779033703, 3144134277, 1013904242, 2773480762, 1359893119,
            2600822924, 528734635, 1541459225,
          ];
          this.k = sha256_K;
          this.W = new Array(64);
        }
        utils.inherits(SHA256, BlockHash);
        module.exports = SHA256;
        SHA256.blockSize = 512;
        SHA256.outSize = 256;
        SHA256.hmacStrength = 192;
        SHA256.padLength = 64;
        SHA256.prototype._update = function _update(msg, start) {
          var W = this.W;
          for (var i = 0; i < 16; i++) W[i] = msg[start + i];
          for (; i < W.length; i++)
            W[i] = sum32_4(
              g1_256(W[i - 2]),
              W[i - 7],
              g0_256(W[i - 15]),
              W[i - 16]
            );
          var a = this.h[0];
          var b = this.h[1];
          var c = this.h[2];
          var d = this.h[3];
          var e = this.h[4];
          var f = this.h[5];
          var g = this.h[6];
          var h = this.h[7];
          assert(this.k.length === W.length);
          for (i = 0; i < W.length; i++) {
            var T1 = sum32_5(h, s1_256(e), ch32(e, f, g), this.k[i], W[i]);
            var T2 = sum32(s0_256(a), maj32(a, b, c));
            h = g;
            g = f;
            f = e;
            e = sum32(d, T1);
            d = c;
            c = b;
            b = a;
            a = sum32(T1, T2);
          }
          this.h[0] = sum32(this.h[0], a);
          this.h[1] = sum32(this.h[1], b);
          this.h[2] = sum32(this.h[2], c);
          this.h[3] = sum32(this.h[3], d);
          this.h[4] = sum32(this.h[4], e);
          this.h[5] = sum32(this.h[5], f);
          this.h[6] = sum32(this.h[6], g);
          this.h[7] = sum32(this.h[7], h);
        };
        SHA256.prototype._digest = function digest(enc) {
          if (enc === "hex") return utils.toHex32(this.h, "big");
          else return utils.split32(this.h, "big");
        };
      },
      {
        "../common": 81,
        "../utils": 91,
        "./common": 90,
        "minimalistic-assert": 119,
      },
    ],
    88: [
      function (require, module, exports) {
        "use strict";
        var utils = require("../utils");
        var SHA512 = require("./512");
        function SHA384() {
          if (!(this instanceof SHA384)) return new SHA384();
          SHA512.call(this);
          this.h = [
            3418070365, 3238371032, 1654270250, 914150663, 2438529370,
            812702999, 355462360, 4144912697, 1731405415, 4290775857,
            2394180231, 1750603025, 3675008525, 1694076839, 1203062813,
            3204075428,
          ];
        }
        utils.inherits(SHA384, SHA512);
        module.exports = SHA384;
        SHA384.blockSize = 1024;
        SHA384.outSize = 384;
        SHA384.hmacStrength = 192;
        SHA384.padLength = 128;
        SHA384.prototype._digest = function digest(enc) {
          if (enc === "hex") return utils.toHex32(this.h.slice(0, 12), "big");
          else return utils.split32(this.h.slice(0, 12), "big");
        };
      },
      { "../utils": 91, "./512": 89 },
    ],
    89: [
      function (require, module, exports) {
        "use strict";
        var utils = require("../utils");
        var common = require("../common");
        var assert = require("minimalistic-assert");
        var rotr64_hi = utils.rotr64_hi;
        var rotr64_lo = utils.rotr64_lo;
        var shr64_hi = utils.shr64_hi;
        var shr64_lo = utils.shr64_lo;
        var sum64 = utils.sum64;
        var sum64_hi = utils.sum64_hi;
        var sum64_lo = utils.sum64_lo;
        var sum64_4_hi = utils.sum64_4_hi;
        var sum64_4_lo = utils.sum64_4_lo;
        var sum64_5_hi = utils.sum64_5_hi;
        var sum64_5_lo = utils.sum64_5_lo;
        var BlockHash = common.BlockHash;
        var sha512_K = [
          1116352408, 3609767458, 1899447441, 602891725, 3049323471, 3964484399,
          3921009573, 2173295548, 961987163, 4081628472, 1508970993, 3053834265,
          2453635748, 2937671579, 2870763221, 3664609560, 3624381080,
          2734883394, 310598401, 1164996542, 607225278, 1323610764, 1426881987,
          3590304994, 1925078388, 4068182383, 2162078206, 991336113, 2614888103,
          633803317, 3248222580, 3479774868, 3835390401, 2666613458, 4022224774,
          944711139, 264347078, 2341262773, 604807628, 2007800933, 770255983,
          1495990901, 1249150122, 1856431235, 1555081692, 3175218132,
          1996064986, 2198950837, 2554220882, 3999719339, 2821834349, 766784016,
          2952996808, 2566594879, 3210313671, 3203337956, 3336571891,
          1034457026, 3584528711, 2466948901, 113926993, 3758326383, 338241895,
          168717936, 666307205, 1188179964, 773529912, 1546045734, 1294757372,
          1522805485, 1396182291, 2643833823, 1695183700, 2343527390,
          1986661051, 1014477480, 2177026350, 1206759142, 2456956037, 344077627,
          2730485921, 1290863460, 2820302411, 3158454273, 3259730800,
          3505952657, 3345764771, 106217008, 3516065817, 3606008344, 3600352804,
          1432725776, 4094571909, 1467031594, 275423344, 851169720, 430227734,
          3100823752, 506948616, 1363258195, 659060556, 3750685593, 883997877,
          3785050280, 958139571, 3318307427, 1322822218, 3812723403, 1537002063,
          2003034995, 1747873779, 3602036899, 1955562222, 1575990012,
          2024104815, 1125592928, 2227730452, 2716904306, 2361852424, 442776044,
          2428436474, 593698344, 2756734187, 3733110249, 3204031479, 2999351573,
          3329325298, 3815920427, 3391569614, 3928383900, 3515267271, 566280711,
          3940187606, 3454069534, 4118630271, 4000239992, 116418474, 1914138554,
          174292421, 2731055270, 289380356, 3203993006, 460393269, 320620315,
          685471733, 587496836, 852142971, 1086792851, 1017036298, 365543100,
          1126000580, 2618297676, 1288033470, 3409855158, 1501505948,
          4234509866, 1607167915, 987167468, 1816402316, 1246189591,
        ];
        function SHA512() {
          if (!(this instanceof SHA512)) return new SHA512();
          BlockHash.call(this);
          this.h = [
            1779033703, 4089235720, 3144134277, 2227873595, 1013904242,
            4271175723, 2773480762, 1595750129, 1359893119, 2917565137,
            2600822924, 725511199, 528734635, 4215389547, 1541459225, 327033209,
          ];
          this.k = sha512_K;
          this.W = new Array(160);
        }
        utils.inherits(SHA512, BlockHash);
        module.exports = SHA512;
        SHA512.blockSize = 1024;
        SHA512.outSize = 512;
        SHA512.hmacStrength = 192;
        SHA512.padLength = 128;
        SHA512.prototype._prepareBlock = function _prepareBlock(msg, start) {
          var W = this.W;
          for (var i = 0; i < 32; i++) W[i] = msg[start + i];
          for (; i < W.length; i += 2) {
            var c0_hi = g1_512_hi(W[i - 4], W[i - 3]);
            var c0_lo = g1_512_lo(W[i - 4], W[i - 3]);
            var c1_hi = W[i - 14];
            var c1_lo = W[i - 13];
            var c2_hi = g0_512_hi(W[i - 30], W[i - 29]);
            var c2_lo = g0_512_lo(W[i - 30], W[i - 29]);
            var c3_hi = W[i - 32];
            var c3_lo = W[i - 31];
            W[i] = sum64_4_hi(
              c0_hi,
              c0_lo,
              c1_hi,
              c1_lo,
              c2_hi,
              c2_lo,
              c3_hi,
              c3_lo
            );
            W[i + 1] = sum64_4_lo(
              c0_hi,
              c0_lo,
              c1_hi,
              c1_lo,
              c2_hi,
              c2_lo,
              c3_hi,
              c3_lo
            );
          }
        };
        SHA512.prototype._update = function _update(msg, start) {
          this._prepareBlock(msg, start);
          var W = this.W;
          var ah = this.h[0];
          var al = this.h[1];
          var bh = this.h[2];
          var bl = this.h[3];
          var ch = this.h[4];
          var cl = this.h[5];
          var dh = this.h[6];
          var dl = this.h[7];
          var eh = this.h[8];
          var el = this.h[9];
          var fh = this.h[10];
          var fl = this.h[11];
          var gh = this.h[12];
          var gl = this.h[13];
          var hh = this.h[14];
          var hl = this.h[15];
          assert(this.k.length === W.length);
          for (var i = 0; i < W.length; i += 2) {
            var c0_hi = hh;
            var c0_lo = hl;
            var c1_hi = s1_512_hi(eh, el);
            var c1_lo = s1_512_lo(eh, el);
            var c2_hi = ch64_hi(eh, el, fh, fl, gh, gl);
            var c2_lo = ch64_lo(eh, el, fh, fl, gh, gl);
            var c3_hi = this.k[i];
            var c3_lo = this.k[i + 1];
            var c4_hi = W[i];
            var c4_lo = W[i + 1];
            var T1_hi = sum64_5_hi(
              c0_hi,
              c0_lo,
              c1_hi,
              c1_lo,
              c2_hi,
              c2_lo,
              c3_hi,
              c3_lo,
              c4_hi,
              c4_lo
            );
            var T1_lo = sum64_5_lo(
              c0_hi,
              c0_lo,
              c1_hi,
              c1_lo,
              c2_hi,
              c2_lo,
              c3_hi,
              c3_lo,
              c4_hi,
              c4_lo
            );
            c0_hi = s0_512_hi(ah, al);
            c0_lo = s0_512_lo(ah, al);
            c1_hi = maj64_hi(ah, al, bh, bl, ch, cl);
            c1_lo = maj64_lo(ah, al, bh, bl, ch, cl);
            var T2_hi = sum64_hi(c0_hi, c0_lo, c1_hi, c1_lo);
            var T2_lo = sum64_lo(c0_hi, c0_lo, c1_hi, c1_lo);
            hh = gh;
            hl = gl;
            gh = fh;
            gl = fl;
            fh = eh;
            fl = el;
            eh = sum64_hi(dh, dl, T1_hi, T1_lo);
            el = sum64_lo(dl, dl, T1_hi, T1_lo);
            dh = ch;
            dl = cl;
            ch = bh;
            cl = bl;
            bh = ah;
            bl = al;
            ah = sum64_hi(T1_hi, T1_lo, T2_hi, T2_lo);
            al = sum64_lo(T1_hi, T1_lo, T2_hi, T2_lo);
          }
          sum64(this.h, 0, ah, al);
          sum64(this.h, 2, bh, bl);
          sum64(this.h, 4, ch, cl);
          sum64(this.h, 6, dh, dl);
          sum64(this.h, 8, eh, el);
          sum64(this.h, 10, fh, fl);
          sum64(this.h, 12, gh, gl);
          sum64(this.h, 14, hh, hl);
        };
        SHA512.prototype._digest = function digest(enc) {
          if (enc === "hex") return utils.toHex32(this.h, "big");
          else return utils.split32(this.h, "big");
        };
        function ch64_hi(xh, xl, yh, yl, zh) {
          var r = (xh & yh) ^ (~xh & zh);
          if (r < 0) r += 4294967296;
          return r;
        }
        function ch64_lo(xh, xl, yh, yl, zh, zl) {
          var r = (xl & yl) ^ (~xl & zl);
          if (r < 0) r += 4294967296;
          return r;
        }
        function maj64_hi(xh, xl, yh, yl, zh) {
          var r = (xh & yh) ^ (xh & zh) ^ (yh & zh);
          if (r < 0) r += 4294967296;
          return r;
        }
        function maj64_lo(xh, xl, yh, yl, zh, zl) {
          var r = (xl & yl) ^ (xl & zl) ^ (yl & zl);
          if (r < 0) r += 4294967296;
          return r;
        }
        function s0_512_hi(xh, xl) {
          var c0_hi = rotr64_hi(xh, xl, 28);
          var c1_hi = rotr64_hi(xl, xh, 2);
          var c2_hi = rotr64_hi(xl, xh, 7);
          var r = c0_hi ^ c1_hi ^ c2_hi;
          if (r < 0) r += 4294967296;
          return r;
        }
        function s0_512_lo(xh, xl) {
          var c0_lo = rotr64_lo(xh, xl, 28);
          var c1_lo = rotr64_lo(xl, xh, 2);
          var c2_lo = rotr64_lo(xl, xh, 7);
          var r = c0_lo ^ c1_lo ^ c2_lo;
          if (r < 0) r += 4294967296;
          return r;
        }
        function s1_512_hi(xh, xl) {
          var c0_hi = rotr64_hi(xh, xl, 14);
          var c1_hi = rotr64_hi(xh, xl, 18);
          var c2_hi = rotr64_hi(xl, xh, 9);
          var r = c0_hi ^ c1_hi ^ c2_hi;
          if (r < 0) r += 4294967296;
          return r;
        }
        function s1_512_lo(xh, xl) {
          var c0_lo = rotr64_lo(xh, xl, 14);
          var c1_lo = rotr64_lo(xh, xl, 18);
          var c2_lo = rotr64_lo(xl, xh, 9);
          var r = c0_lo ^ c1_lo ^ c2_lo;
          if (r < 0) r += 4294967296;
          return r;
        }
        function g0_512_hi(xh, xl) {
          var c0_hi = rotr64_hi(xh, xl, 1);
          var c1_hi = rotr64_hi(xh, xl, 8);
          var c2_hi = shr64_hi(xh, xl, 7);
          var r = c0_hi ^ c1_hi ^ c2_hi;
          if (r < 0) r += 4294967296;
          return r;
        }
        function g0_512_lo(xh, xl) {
          var c0_lo = rotr64_lo(xh, xl, 1);
          var c1_lo = rotr64_lo(xh, xl, 8);
          var c2_lo = shr64_lo(xh, xl, 7);
          var r = c0_lo ^ c1_lo ^ c2_lo;
          if (r < 0) r += 4294967296;
          return r;
        }
        function g1_512_hi(xh, xl) {
          var c0_hi = rotr64_hi(xh, xl, 19);
          var c1_hi = rotr64_hi(xl, xh, 29);
          var c2_hi = shr64_hi(xh, xl, 6);
          var r = c0_hi ^ c1_hi ^ c2_hi;
          if (r < 0) r += 4294967296;
          return r;
        }
        function g1_512_lo(xh, xl) {
          var c0_lo = rotr64_lo(xh, xl, 19);
          var c1_lo = rotr64_lo(xl, xh, 29);
          var c2_lo = shr64_lo(xh, xl, 6);
          var r = c0_lo ^ c1_lo ^ c2_lo;
          if (r < 0) r += 4294967296;
          return r;
        }
      },
      { "../common": 81, "../utils": 91, "minimalistic-assert": 119 },
    ],
    90: [
      function (require, module, exports) {
        "use strict";
        var utils = require("../utils");
        var rotr32 = utils.rotr32;
        function ft_1(s, x, y, z) {
          if (s === 0) return ch32(x, y, z);
          if (s === 1 || s === 3) return p32(x, y, z);
          if (s === 2) return maj32(x, y, z);
        }
        exports.ft_1 = ft_1;
        function ch32(x, y, z) {
          return (x & y) ^ (~x & z);
        }
        exports.ch32 = ch32;
        function maj32(x, y, z) {
          return (x & y) ^ (x & z) ^ (y & z);
        }
        exports.maj32 = maj32;
        function p32(x, y, z) {
          return x ^ y ^ z;
        }
        exports.p32 = p32;
        function s0_256(x) {
          return rotr32(x, 2) ^ rotr32(x, 13) ^ rotr32(x, 22);
        }
        exports.s0_256 = s0_256;
        function s1_256(x) {
          return rotr32(x, 6) ^ rotr32(x, 11) ^ rotr32(x, 25);
        }
        exports.s1_256 = s1_256;
        function g0_256(x) {
          return rotr32(x, 7) ^ rotr32(x, 18) ^ (x >>> 3);
        }
        exports.g0_256 = g0_256;
        function g1_256(x) {
          return rotr32(x, 17) ^ rotr32(x, 19) ^ (x >>> 10);
        }
        exports.g1_256 = g1_256;
      },
      { "../utils": 91 },
    ],
    91: [
      function (require, module, exports) {
        "use strict";
        var assert = require("minimalistic-assert");
        var inherits = require("inherits");
        exports.inherits = inherits;
        function isSurrogatePair(msg, i) {
          if ((msg.charCodeAt(i) & 64512) !== 55296) {
            return false;
          }
          if (i < 0 || i + 1 >= msg.length) {
            return false;
          }
          return (msg.charCodeAt(i + 1) & 64512) === 56320;
        }
        function toArray(msg, enc) {
          if (Array.isArray(msg)) return msg.slice();
          if (!msg) return [];
          var res = [];
          if (typeof msg === "string") {
            if (!enc) {
              var p = 0;
              for (var i = 0; i < msg.length; i++) {
                var c = msg.charCodeAt(i);
                if (c < 128) {
                  res[p++] = c;
                } else if (c < 2048) {
                  res[p++] = (c >> 6) | 192;
                  res[p++] = (c & 63) | 128;
                } else if (isSurrogatePair(msg, i)) {
                  c = 65536 + ((c & 1023) << 10) + (msg.charCodeAt(++i) & 1023);
                  res[p++] = (c >> 18) | 240;
                  res[p++] = ((c >> 12) & 63) | 128;
                  res[p++] = ((c >> 6) & 63) | 128;
                  res[p++] = (c & 63) | 128;
                } else {
                  res[p++] = (c >> 12) | 224;
                  res[p++] = ((c >> 6) & 63) | 128;
                  res[p++] = (c & 63) | 128;
                }
              }
            } else if (enc === "hex") {
              msg = msg.replace(/[^a-z0-9]+/gi, "");
              if (msg.length % 2 !== 0) msg = "0" + msg;
              for (i = 0; i < msg.length; i += 2)
                res.push(parseInt(msg[i] + msg[i + 1], 16));
            }
          } else {
            for (i = 0; i < msg.length; i++) res[i] = msg[i] | 0;
          }
          return res;
        }
        exports.toArray = toArray;
        function toHex(msg) {
          var res = "";
          for (var i = 0; i < msg.length; i++)
            res += zero2(msg[i].toString(16));
          return res;
        }
        exports.toHex = toHex;
        function htonl(w) {
          var res =
            (w >>> 24) |
            ((w >>> 8) & 65280) |
            ((w << 8) & 16711680) |
            ((w & 255) << 24);
          return res >>> 0;
        }
        exports.htonl = htonl;
        function toHex32(msg, endian) {
          var res = "";
          for (var i = 0; i < msg.length; i++) {
            var w = msg[i];
            if (endian === "little") w = htonl(w);
            res += zero8(w.toString(16));
          }
          return res;
        }
        exports.toHex32 = toHex32;
        function zero2(word) {
          if (word.length === 1) return "0" + word;
          else return word;
        }
        exports.zero2 = zero2;
        function zero8(word) {
          if (word.length === 7) return "0" + word;
          else if (word.length === 6) return "00" + word;
          else if (word.length === 5) return "000" + word;
          else if (word.length === 4) return "0000" + word;
          else if (word.length === 3) return "00000" + word;
          else if (word.length === 2) return "000000" + word;
          else if (word.length === 1) return "0000000" + word;
          else return word;
        }
        exports.zero8 = zero8;
        function join32(msg, start, end, endian) {
          var len = end - start;
          assert(len % 4 === 0);
          var res = new Array(len / 4);
          for (var i = 0, k = start; i < res.length; i++, k += 4) {
            var w;
            if (endian === "big")
              w =
                (msg[k] << 24) |
                (msg[k + 1] << 16) |
                (msg[k + 2] << 8) |
                msg[k + 3];
            else
              w =
                (msg[k + 3] << 24) |
                (msg[k + 2] << 16) |
                (msg[k + 1] << 8) |
                msg[k];
            res[i] = w >>> 0;
          }
          return res;
        }
        exports.join32 = join32;
        function split32(msg, endian) {
          var res = new Array(msg.length * 4);
          for (var i = 0, k = 0; i < msg.length; i++, k += 4) {
            var m = msg[i];
            if (endian === "big") {
              res[k] = m >>> 24;
              res[k + 1] = (m >>> 16) & 255;
              res[k + 2] = (m >>> 8) & 255;
              res[k + 3] = m & 255;
            } else {
              res[k + 3] = m >>> 24;
              res[k + 2] = (m >>> 16) & 255;
              res[k + 1] = (m >>> 8) & 255;
              res[k] = m & 255;
            }
          }
          return res;
        }
        exports.split32 = split32;
        function rotr32(w, b) {
          return (w >>> b) | (w << (32 - b));
        }
        exports.rotr32 = rotr32;
        function rotl32(w, b) {
          return (w << b) | (w >>> (32 - b));
        }
        exports.rotl32 = rotl32;
        function sum32(a, b) {
          return (a + b) >>> 0;
        }
        exports.sum32 = sum32;
        function sum32_3(a, b, c) {
          return (a + b + c) >>> 0;
        }
        exports.sum32_3 = sum32_3;
        function sum32_4(a, b, c, d) {
          return (a + b + c + d) >>> 0;
        }
        exports.sum32_4 = sum32_4;
        function sum32_5(a, b, c, d, e) {
          return (a + b + c + d + e) >>> 0;
        }
        exports.sum32_5 = sum32_5;
        function sum64(buf, pos, ah, al) {
          var bh = buf[pos];
          var bl = buf[pos + 1];
          var lo = (al + bl) >>> 0;
          var hi = (lo < al ? 1 : 0) + ah + bh;
          buf[pos] = hi >>> 0;
          buf[pos + 1] = lo;
        }
        exports.sum64 = sum64;
        function sum64_hi(ah, al, bh, bl) {
          var lo = (al + bl) >>> 0;
          var hi = (lo < al ? 1 : 0) + ah + bh;
          return hi >>> 0;
        }
        exports.sum64_hi = sum64_hi;
        function sum64_lo(ah, al, bh, bl) {
          var lo = al + bl;
          return lo >>> 0;
        }
        exports.sum64_lo = sum64_lo;
        function sum64_4_hi(ah, al, bh, bl, ch, cl, dh, dl) {
          var carry = 0;
          var lo = al;
          lo = (lo + bl) >>> 0;
          carry += lo < al ? 1 : 0;
          lo = (lo + cl) >>> 0;
          carry += lo < cl ? 1 : 0;
          lo = (lo + dl) >>> 0;
          carry += lo < dl ? 1 : 0;
          var hi = ah + bh + ch + dh + carry;
          return hi >>> 0;
        }
        exports.sum64_4_hi = sum64_4_hi;
        function sum64_4_lo(ah, al, bh, bl, ch, cl, dh, dl) {
          var lo = al + bl + cl + dl;
          return lo >>> 0;
        }
        exports.sum64_4_lo = sum64_4_lo;
        function sum64_5_hi(ah, al, bh, bl, ch, cl, dh, dl, eh, el) {
          var carry = 0;
          var lo = al;
          lo = (lo + bl) >>> 0;
          carry += lo < al ? 1 : 0;
          lo = (lo + cl) >>> 0;
          carry += lo < cl ? 1 : 0;
          lo = (lo + dl) >>> 0;
          carry += lo < dl ? 1 : 0;
          lo = (lo + el) >>> 0;
          carry += lo < el ? 1 : 0;
          var hi = ah + bh + ch + dh + eh + carry;
          return hi >>> 0;
        }
        exports.sum64_5_hi = sum64_5_hi;
        function sum64_5_lo(ah, al, bh, bl, ch, cl, dh, dl, eh, el) {
          var lo = al + bl + cl + dl + el;
          return lo >>> 0;
        }
        exports.sum64_5_lo = sum64_5_lo;
        function rotr64_hi(ah, al, num) {
          var r = (al << (32 - num)) | (ah >>> num);
          return r >>> 0;
        }
        exports.rotr64_hi = rotr64_hi;
        function rotr64_lo(ah, al, num) {
          var r = (ah << (32 - num)) | (al >>> num);
          return r >>> 0;
        }
        exports.rotr64_lo = rotr64_lo;
        function shr64_hi(ah, al, num) {
          return ah >>> num;
        }
        exports.shr64_hi = shr64_hi;
        function shr64_lo(ah, al, num) {
          var r = (ah << (32 - num)) | (al >>> num);
          return r >>> 0;
        }
        exports.shr64_lo = shr64_lo;
      },
      { inherits: 94, "minimalistic-assert": 119 },
    ],
    92: [
      function (require, module, exports) {
        "use strict";
        var hash = require("hash.js");
        var utils = require("minimalistic-crypto-utils");
        var assert = require("minimalistic-assert");
        function HmacDRBG(options) {
          if (!(this instanceof HmacDRBG)) return new HmacDRBG(options);
          this.hash = options.hash;
          this.predResist = !!options.predResist;
          this.outLen = this.hash.outSize;
          this.minEntropy = options.minEntropy || this.hash.hmacStrength;
          this._reseed = null;
          this.reseedInterval = null;
          this.K = null;
          this.V = null;
          var entropy = utils.toArray(
            options.entropy,
            options.entropyEnc || "hex"
          );
          var nonce = utils.toArray(options.nonce, options.nonceEnc || "hex");
          var pers = utils.toArray(options.pers, options.persEnc || "hex");
          assert(
            entropy.length >= this.minEntropy / 8,
            "Not enough entropy. Minimum is: " + this.minEntropy + " bits"
          );
          this._init(entropy, nonce, pers);
        }
        module.exports = HmacDRBG;
        HmacDRBG.prototype._init = function init(entropy, nonce, pers) {
          var seed = entropy.concat(nonce).concat(pers);
          this.K = new Array(this.outLen / 8);
          this.V = new Array(this.outLen / 8);
          for (var i = 0; i < this.V.length; i++) {
            this.K[i] = 0;
            this.V[i] = 1;
          }
          this._update(seed);
          this._reseed = 1;
          this.reseedInterval = 281474976710656;
        };
        HmacDRBG.prototype._hmac = function hmac() {
          return new hash.hmac(this.hash, this.K);
        };
        HmacDRBG.prototype._update = function update(seed) {
          var kmac = this._hmac().update(this.V).update([0]);
          if (seed) kmac = kmac.update(seed);
          this.K = kmac.digest();
          this.V = this._hmac().update(this.V).digest();
          if (!seed) return;
          this.K = this._hmac()
            .update(this.V)
            .update([1])
            .update(seed)
            .digest();
          this.V = this._hmac().update(this.V).digest();
        };
        HmacDRBG.prototype.reseed = function reseed(
          entropy,
          entropyEnc,
          add,
          addEnc
        ) {
          if (typeof entropyEnc !== "string") {
            addEnc = add;
            add = entropyEnc;
            entropyEnc = null;
          }
          entropy = utils.toArray(entropy, entropyEnc);
          add = utils.toArray(add, addEnc);
          assert(
            entropy.length >= this.minEntropy / 8,
            "Not enough entropy. Minimum is: " + this.minEntropy + " bits"
          );
          this._update(entropy.concat(add || []));
          this._reseed = 1;
        };
        HmacDRBG.prototype.generate = function generate(len, enc, add, addEnc) {
          if (this._reseed > this.reseedInterval)
            throw new Error("Reseed is required");
          if (typeof enc !== "string") {
            addEnc = add;
            add = enc;
            enc = null;
          }
          if (add) {
            add = utils.toArray(add, addEnc || "hex");
            this._update(add);
          }
          var temp = [];
          while (temp.length < len) {
            this.V = this._hmac().update(this.V).digest();
            temp = temp.concat(this.V);
          }
          var res = temp.slice(0, len);
          this._update(add);
          this._reseed++;
          return utils.encode(res, enc);
        };
      },
      {
        "hash.js": 80,
        "minimalistic-assert": 119,
        "minimalistic-crypto-utils": 120,
      },
    ],
    93: [
      function (require, module, exports) {
        exports.read = function (buffer, offset, isLE, mLen, nBytes) {
          var e, m;
          var eLen = nBytes * 8 - mLen - 1;
          var eMax = (1 << eLen) - 1;
          var eBias = eMax >> 1;
          var nBits = -7;
          var i = isLE ? nBytes - 1 : 0;
          var d = isLE ? -1 : 1;
          var s = buffer[offset + i];
          i += d;
          e = s & ((1 << -nBits) - 1);
          s >>= -nBits;
          nBits += eLen;
          for (
            ;
            nBits > 0;
            e = e * 256 + buffer[offset + i], i += d, nBits -= 8
          ) {}
          m = e & ((1 << -nBits) - 1);
          e >>= -nBits;
          nBits += mLen;
          for (
            ;
            nBits > 0;
            m = m * 256 + buffer[offset + i], i += d, nBits -= 8
          ) {}
          if (e === 0) {
            e = 1 - eBias;
          } else if (e === eMax) {
            return m ? NaN : (s ? -1 : 1) * Infinity;
          } else {
            m = m + Math.pow(2, mLen);
            e = e - eBias;
          }
          return (s ? -1 : 1) * m * Math.pow(2, e - mLen);
        };
        exports.write = function (buffer, value, offset, isLE, mLen, nBytes) {
          var e, m, c;
          var eLen = nBytes * 8 - mLen - 1;
          var eMax = (1 << eLen) - 1;
          var eBias = eMax >> 1;
          var rt = mLen === 23 ? Math.pow(2, -24) - Math.pow(2, -77) : 0;
          var i = isLE ? 0 : nBytes - 1;
          var d = isLE ? 1 : -1;
          var s = value < 0 || (value === 0 && 1 / value < 0) ? 1 : 0;
          value = Math.abs(value);
          if (isNaN(value) || value === Infinity) {
            m = isNaN(value) ? 1 : 0;
            e = eMax;
          } else {
            e = Math.floor(Math.log(value) / Math.LN2);
            if (value * (c = Math.pow(2, -e)) < 1) {
              e--;
              c *= 2;
            }
            if (e + eBias >= 1) {
              value += rt / c;
            } else {
              value += rt * Math.pow(2, 1 - eBias);
            }
            if (value * c >= 2) {
              e++;
              c /= 2;
            }
            if (e + eBias >= eMax) {
              m = 0;
              e = eMax;
            } else if (e + eBias >= 1) {
              m = (value * c - 1) * Math.pow(2, mLen);
              e = e + eBias;
            } else {
              m = value * Math.pow(2, eBias - 1) * Math.pow(2, mLen);
              e = 0;
            }
          }
          for (
            ;
            mLen >= 8;
            buffer[offset + i] = m & 255, i += d, m /= 256, mLen -= 8
          ) {}
          e = (e << mLen) | m;
          eLen += mLen;
          for (
            ;
            eLen > 0;
            buffer[offset + i] = e & 255, i += d, e /= 256, eLen -= 8
          ) {}
          buffer[offset + i - d] |= s * 128;
        };
      },
      {},
    ],
    94: [
      function (require, module, exports) {
        if (typeof Object.create === "function") {
          module.exports = function inherits(ctor, superCtor) {
            if (superCtor) {
              ctor.super_ = superCtor;
              ctor.prototype = Object.create(superCtor.prototype, {
                constructor: {
                  value: ctor,
                  enumerable: false,
                  writable: true,
                  configurable: true,
                },
              });
            }
          };
        } else {
          module.exports = function inherits(ctor, superCtor) {
            if (superCtor) {
              ctor.super_ = superCtor;
              var TempCtor = function () {};
              TempCtor.prototype = superCtor.prototype;
              ctor.prototype = new TempCtor();
              ctor.prototype.constructor = ctor;
            }
          };
        }
      },
      {},
    ],
    95: [
      function (require, module, exports) {
        module.exports = function isHexPrefixed(str) {
          if (typeof str !== "string") {
            throw new Error(
              "[is-hex-prefixed] value must be type 'string', is currently type " +
                typeof str +
                ", while checking isHexPrefixed."
            );
          }
          return str.slice(0, 2) === "0x";
        };
      },
      {},
    ],
    96: [
      function (require, module, exports) {
        "use strict";
        function isUtf8(buf) {
          if (!buf) {
            return false;
          }
          let i = 0;
          const len = buf.length;
          while (i < len) {
            if (buf[i] <= 127) {
              i++;
              continue;
            }
            if (buf[i] >= 194 && buf[i] <= 223) {
              if (buf[i + 1] >> 6 === 2) {
                i += 2;
                continue;
              } else {
                return false;
              }
            }
            if (
              ((buf[i] === 224 && buf[i + 1] >= 160 && buf[i + 1] <= 191) ||
                (buf[i] === 237 && buf[i + 1] >= 128 && buf[i + 1] <= 159)) &&
              buf[i + 2] >> 6 === 2
            ) {
              i += 3;
              continue;
            }
            if (
              ((buf[i] >= 225 && buf[i] <= 236) ||
                (buf[i] >= 238 && buf[i] <= 239)) &&
              buf[i + 1] >> 6 === 2 &&
              buf[i + 2] >> 6 === 2
            ) {
              i += 3;
              continue;
            }
            if (
              ((buf[i] === 240 && buf[i + 1] >= 144 && buf[i + 1] <= 191) ||
                (buf[i] >= 241 && buf[i] <= 243 && buf[i + 1] >> 6 === 2) ||
                (buf[i] === 244 && buf[i + 1] >= 128 && buf[i + 1] <= 143)) &&
              buf[i + 2] >> 6 === 2 &&
              buf[i + 3] >> 6 === 2
            ) {
              i += 4;
              continue;
            }
            return false;
          }
          return true;
        }
        module.exports = isUtf8;
      },
      {},
    ],
    97: [
      function (require, module, exports) {
        module.exports = require("./lib/api")(require("./lib/keccak"));
      },
      { "./lib/api": 98, "./lib/keccak": 102 },
    ],
    98: [
      function (require, module, exports) {
        const createKeccak = require("./keccak");
        const createShake = require("./shake");
        module.exports = function (KeccakState) {
          const Keccak = createKeccak(KeccakState);
          const Shake = createShake(KeccakState);
          return function (algorithm, options) {
            const hash =
              typeof algorithm === "string"
                ? algorithm.toLowerCase()
                : algorithm;
            switch (hash) {
              case "keccak224":
                return new Keccak(1152, 448, null, 224, options);
              case "keccak256":
                return new Keccak(1088, 512, null, 256, options);
              case "keccak384":
                return new Keccak(832, 768, null, 384, options);
              case "keccak512":
                return new Keccak(576, 1024, null, 512, options);
              case "sha3-224":
                return new Keccak(1152, 448, 6, 224, options);
              case "sha3-256":
                return new Keccak(1088, 512, 6, 256, options);
              case "sha3-384":
                return new Keccak(832, 768, 6, 384, options);
              case "sha3-512":
                return new Keccak(576, 1024, 6, 512, options);
              case "shake128":
                return new Shake(1344, 256, 31, options);
              case "shake256":
                return new Shake(1088, 512, 31, options);
              default:
                throw new Error("Invald algorithm: " + algorithm);
            }
          };
        };
      },
      { "./keccak": 99, "./shake": 100 },
    ],
    99: [
      function (require, module, exports) {
        (function (Buffer) {
          (function () {
            const { Transform } = require("readable-stream");
            module.exports = (KeccakState) =>
              class Keccak extends Transform {
                constructor(
                  rate,
                  capacity,
                  delimitedSuffix,
                  hashBitLength,
                  options
                ) {
                  super(options);
                  this._rate = rate;
                  this._capacity = capacity;
                  this._delimitedSuffix = delimitedSuffix;
                  this._hashBitLength = hashBitLength;
                  this._options = options;
                  this._state = new KeccakState();
                  this._state.initialize(rate, capacity);
                  this._finalized = false;
                }
                _transform(chunk, encoding, callback) {
                  let error = null;
                  try {
                    this.update(chunk, encoding);
                  } catch (err) {
                    error = err;
                  }
                  callback(error);
                }
                _flush(callback) {
                  let error = null;
                  try {
                    this.push(this.digest());
                  } catch (err) {
                    error = err;
                  }
                  callback(error);
                }
                update(data, encoding) {
                  if (!Buffer.isBuffer(data) && typeof data !== "string")
                    throw new TypeError("Data must be a string or a buffer");
                  if (this._finalized) throw new Error("Digest already called");
                  if (!Buffer.isBuffer(data))
                    data = Buffer.from(data, encoding);
                  this._state.absorb(data);
                  return this;
                }
                digest(encoding) {
                  if (this._finalized) throw new Error("Digest already called");
                  this._finalized = true;
                  if (this._delimitedSuffix)
                    this._state.absorbLastFewBits(this._delimitedSuffix);
                  let digest = this._state.squeeze(this._hashBitLength / 8);
                  if (encoding !== undefined)
                    digest = digest.toString(encoding);
                  this._resetState();
                  return digest;
                }
                _resetState() {
                  this._state.initialize(this._rate, this._capacity);
                  return this;
                }
                _clone() {
                  const clone = new Keccak(
                    this._rate,
                    this._capacity,
                    this._delimitedSuffix,
                    this._hashBitLength,
                    this._options
                  );
                  this._state.copy(clone._state);
                  clone._finalized = this._finalized;
                  return clone;
                }
              };
          }).call(this);
        }).call(this, require("buffer").Buffer);
      },
      { buffer: 25, "readable-stream": 117 },
    ],
    100: [
      function (require, module, exports) {
        (function (Buffer) {
          (function () {
            const { Transform } = require("readable-stream");
            module.exports = (KeccakState) =>
              class Shake extends Transform {
                constructor(rate, capacity, delimitedSuffix, options) {
                  super(options);
                  this._rate = rate;
                  this._capacity = capacity;
                  this._delimitedSuffix = delimitedSuffix;
                  this._options = options;
                  this._state = new KeccakState();
                  this._state.initialize(rate, capacity);
                  this._finalized = false;
                }
                _transform(chunk, encoding, callback) {
                  let error = null;
                  try {
                    this.update(chunk, encoding);
                  } catch (err) {
                    error = err;
                  }
                  callback(error);
                }
                _flush() {}
                _read(size) {
                  this.push(this.squeeze(size));
                }
                update(data, encoding) {
                  if (!Buffer.isBuffer(data) && typeof data !== "string")
                    throw new TypeError("Data must be a string or a buffer");
                  if (this._finalized)
                    throw new Error("Squeeze already called");
                  if (!Buffer.isBuffer(data))
                    data = Buffer.from(data, encoding);
                  this._state.absorb(data);
                  return this;
                }
                squeeze(dataByteLength, encoding) {
                  if (!this._finalized) {
                    this._finalized = true;
                    this._state.absorbLastFewBits(this._delimitedSuffix);
                  }
                  let data = this._state.squeeze(dataByteLength);
                  if (encoding !== undefined) data = data.toString(encoding);
                  return data;
                }
                _resetState() {
                  this._state.initialize(this._rate, this._capacity);
                  return this;
                }
                _clone() {
                  const clone = new Shake(
                    this._rate,
                    this._capacity,
                    this._delimitedSuffix,
                    this._options
                  );
                  this._state.copy(clone._state);
                  clone._finalized = this._finalized;
                  return clone;
                }
              };
          }).call(this);
        }).call(this, require("buffer").Buffer);
      },
      { buffer: 25, "readable-stream": 117 },
    ],
    101: [
      function (require, module, exports) {
        const P1600_ROUND_CONSTANTS = [
          1, 0, 32898, 0, 32906, 2147483648, 2147516416, 2147483648, 32907, 0,
          2147483649, 0, 2147516545, 2147483648, 32777, 2147483648, 138, 0, 136,
          0, 2147516425, 0, 2147483658, 0, 2147516555, 0, 139, 2147483648,
          32905, 2147483648, 32771, 2147483648, 32770, 2147483648, 128,
          2147483648, 32778, 0, 2147483658, 2147483648, 2147516545, 2147483648,
          32896, 2147483648, 2147483649, 0, 2147516424, 2147483648,
        ];
        exports.p1600 = function (s) {
          for (let round = 0; round < 24; ++round) {
            const lo0 = s[0] ^ s[10] ^ s[20] ^ s[30] ^ s[40];
            const hi0 = s[1] ^ s[11] ^ s[21] ^ s[31] ^ s[41];
            const lo1 = s[2] ^ s[12] ^ s[22] ^ s[32] ^ s[42];
            const hi1 = s[3] ^ s[13] ^ s[23] ^ s[33] ^ s[43];
            const lo2 = s[4] ^ s[14] ^ s[24] ^ s[34] ^ s[44];
            const hi2 = s[5] ^ s[15] ^ s[25] ^ s[35] ^ s[45];
            const lo3 = s[6] ^ s[16] ^ s[26] ^ s[36] ^ s[46];
            const hi3 = s[7] ^ s[17] ^ s[27] ^ s[37] ^ s[47];
            const lo4 = s[8] ^ s[18] ^ s[28] ^ s[38] ^ s[48];
            const hi4 = s[9] ^ s[19] ^ s[29] ^ s[39] ^ s[49];
            let lo = lo4 ^ ((lo1 << 1) | (hi1 >>> 31));
            let hi = hi4 ^ ((hi1 << 1) | (lo1 >>> 31));
            const t1slo0 = s[0] ^ lo;
            const t1shi0 = s[1] ^ hi;
            const t1slo5 = s[10] ^ lo;
            const t1shi5 = s[11] ^ hi;
            const t1slo10 = s[20] ^ lo;
            const t1shi10 = s[21] ^ hi;
            const t1slo15 = s[30] ^ lo;
            const t1shi15 = s[31] ^ hi;
            const t1slo20 = s[40] ^ lo;
            const t1shi20 = s[41] ^ hi;
            lo = lo0 ^ ((lo2 << 1) | (hi2 >>> 31));
            hi = hi0 ^ ((hi2 << 1) | (lo2 >>> 31));
            const t1slo1 = s[2] ^ lo;
            const t1shi1 = s[3] ^ hi;
            const t1slo6 = s[12] ^ lo;
            const t1shi6 = s[13] ^ hi;
            const t1slo11 = s[22] ^ lo;
            const t1shi11 = s[23] ^ hi;
            const t1slo16 = s[32] ^ lo;
            const t1shi16 = s[33] ^ hi;
            const t1slo21 = s[42] ^ lo;
            const t1shi21 = s[43] ^ hi;
            lo = lo1 ^ ((lo3 << 1) | (hi3 >>> 31));
            hi = hi1 ^ ((hi3 << 1) | (lo3 >>> 31));
            const t1slo2 = s[4] ^ lo;
            const t1shi2 = s[5] ^ hi;
            const t1slo7 = s[14] ^ lo;
            const t1shi7 = s[15] ^ hi;
            const t1slo12 = s[24] ^ lo;
            const t1shi12 = s[25] ^ hi;
            const t1slo17 = s[34] ^ lo;
            const t1shi17 = s[35] ^ hi;
            const t1slo22 = s[44] ^ lo;
            const t1shi22 = s[45] ^ hi;
            lo = lo2 ^ ((lo4 << 1) | (hi4 >>> 31));
            hi = hi2 ^ ((hi4 << 1) | (lo4 >>> 31));
            const t1slo3 = s[6] ^ lo;
            const t1shi3 = s[7] ^ hi;
            const t1slo8 = s[16] ^ lo;
            const t1shi8 = s[17] ^ hi;
            const t1slo13 = s[26] ^ lo;
            const t1shi13 = s[27] ^ hi;
            const t1slo18 = s[36] ^ lo;
            const t1shi18 = s[37] ^ hi;
            const t1slo23 = s[46] ^ lo;
            const t1shi23 = s[47] ^ hi;
            lo = lo3 ^ ((lo0 << 1) | (hi0 >>> 31));
            hi = hi3 ^ ((hi0 << 1) | (lo0 >>> 31));
            const t1slo4 = s[8] ^ lo;
            const t1shi4 = s[9] ^ hi;
            const t1slo9 = s[18] ^ lo;
            const t1shi9 = s[19] ^ hi;
            const t1slo14 = s[28] ^ lo;
            const t1shi14 = s[29] ^ hi;
            const t1slo19 = s[38] ^ lo;
            const t1shi19 = s[39] ^ hi;
            const t1slo24 = s[48] ^ lo;
            const t1shi24 = s[49] ^ hi;
            const t2slo0 = t1slo0;
            const t2shi0 = t1shi0;
            const t2slo16 = (t1shi5 << 4) | (t1slo5 >>> 28);
            const t2shi16 = (t1slo5 << 4) | (t1shi5 >>> 28);
            const t2slo7 = (t1slo10 << 3) | (t1shi10 >>> 29);
            const t2shi7 = (t1shi10 << 3) | (t1slo10 >>> 29);
            const t2slo23 = (t1shi15 << 9) | (t1slo15 >>> 23);
            const t2shi23 = (t1slo15 << 9) | (t1shi15 >>> 23);
            const t2slo14 = (t1slo20 << 18) | (t1shi20 >>> 14);
            const t2shi14 = (t1shi20 << 18) | (t1slo20 >>> 14);
            const t2slo10 = (t1slo1 << 1) | (t1shi1 >>> 31);
            const t2shi10 = (t1shi1 << 1) | (t1slo1 >>> 31);
            const t2slo1 = (t1shi6 << 12) | (t1slo6 >>> 20);
            const t2shi1 = (t1slo6 << 12) | (t1shi6 >>> 20);
            const t2slo17 = (t1slo11 << 10) | (t1shi11 >>> 22);
            const t2shi17 = (t1shi11 << 10) | (t1slo11 >>> 22);
            const t2slo8 = (t1shi16 << 13) | (t1slo16 >>> 19);
            const t2shi8 = (t1slo16 << 13) | (t1shi16 >>> 19);
            const t2slo24 = (t1slo21 << 2) | (t1shi21 >>> 30);
            const t2shi24 = (t1shi21 << 2) | (t1slo21 >>> 30);
            const t2slo20 = (t1shi2 << 30) | (t1slo2 >>> 2);
            const t2shi20 = (t1slo2 << 30) | (t1shi2 >>> 2);
            const t2slo11 = (t1slo7 << 6) | (t1shi7 >>> 26);
            const t2shi11 = (t1shi7 << 6) | (t1slo7 >>> 26);
            const t2slo2 = (t1shi12 << 11) | (t1slo12 >>> 21);
            const t2shi2 = (t1slo12 << 11) | (t1shi12 >>> 21);
            const t2slo18 = (t1slo17 << 15) | (t1shi17 >>> 17);
            const t2shi18 = (t1shi17 << 15) | (t1slo17 >>> 17);
            const t2slo9 = (t1shi22 << 29) | (t1slo22 >>> 3);
            const t2shi9 = (t1slo22 << 29) | (t1shi22 >>> 3);
            const t2slo5 = (t1slo3 << 28) | (t1shi3 >>> 4);
            const t2shi5 = (t1shi3 << 28) | (t1slo3 >>> 4);
            const t2slo21 = (t1shi8 << 23) | (t1slo8 >>> 9);
            const t2shi21 = (t1slo8 << 23) | (t1shi8 >>> 9);
            const t2slo12 = (t1slo13 << 25) | (t1shi13 >>> 7);
            const t2shi12 = (t1shi13 << 25) | (t1slo13 >>> 7);
            const t2slo3 = (t1slo18 << 21) | (t1shi18 >>> 11);
            const t2shi3 = (t1shi18 << 21) | (t1slo18 >>> 11);
            const t2slo19 = (t1shi23 << 24) | (t1slo23 >>> 8);
            const t2shi19 = (t1slo23 << 24) | (t1shi23 >>> 8);
            const t2slo15 = (t1slo4 << 27) | (t1shi4 >>> 5);
            const t2shi15 = (t1shi4 << 27) | (t1slo4 >>> 5);
            const t2slo6 = (t1slo9 << 20) | (t1shi9 >>> 12);
            const t2shi6 = (t1shi9 << 20) | (t1slo9 >>> 12);
            const t2slo22 = (t1shi14 << 7) | (t1slo14 >>> 25);
            const t2shi22 = (t1slo14 << 7) | (t1shi14 >>> 25);
            const t2slo13 = (t1slo19 << 8) | (t1shi19 >>> 24);
            const t2shi13 = (t1shi19 << 8) | (t1slo19 >>> 24);
            const t2slo4 = (t1slo24 << 14) | (t1shi24 >>> 18);
            const t2shi4 = (t1shi24 << 14) | (t1slo24 >>> 18);
            s[0] = t2slo0 ^ (~t2slo1 & t2slo2);
            s[1] = t2shi0 ^ (~t2shi1 & t2shi2);
            s[10] = t2slo5 ^ (~t2slo6 & t2slo7);
            s[11] = t2shi5 ^ (~t2shi6 & t2shi7);
            s[20] = t2slo10 ^ (~t2slo11 & t2slo12);
            s[21] = t2shi10 ^ (~t2shi11 & t2shi12);
            s[30] = t2slo15 ^ (~t2slo16 & t2slo17);
            s[31] = t2shi15 ^ (~t2shi16 & t2shi17);
            s[40] = t2slo20 ^ (~t2slo21 & t2slo22);
            s[41] = t2shi20 ^ (~t2shi21 & t2shi22);
            s[2] = t2slo1 ^ (~t2slo2 & t2slo3);
            s[3] = t2shi1 ^ (~t2shi2 & t2shi3);
            s[12] = t2slo6 ^ (~t2slo7 & t2slo8);
            s[13] = t2shi6 ^ (~t2shi7 & t2shi8);
            s[22] = t2slo11 ^ (~t2slo12 & t2slo13);
            s[23] = t2shi11 ^ (~t2shi12 & t2shi13);
            s[32] = t2slo16 ^ (~t2slo17 & t2slo18);
            s[33] = t2shi16 ^ (~t2shi17 & t2shi18);
            s[42] = t2slo21 ^ (~t2slo22 & t2slo23);
            s[43] = t2shi21 ^ (~t2shi22 & t2shi23);
            s[4] = t2slo2 ^ (~t2slo3 & t2slo4);
            s[5] = t2shi2 ^ (~t2shi3 & t2shi4);
            s[14] = t2slo7 ^ (~t2slo8 & t2slo9);
            s[15] = t2shi7 ^ (~t2shi8 & t2shi9);
            s[24] = t2slo12 ^ (~t2slo13 & t2slo14);
            s[25] = t2shi12 ^ (~t2shi13 & t2shi14);
            s[34] = t2slo17 ^ (~t2slo18 & t2slo19);
            s[35] = t2shi17 ^ (~t2shi18 & t2shi19);
            s[44] = t2slo22 ^ (~t2slo23 & t2slo24);
            s[45] = t2shi22 ^ (~t2shi23 & t2shi24);
            s[6] = t2slo3 ^ (~t2slo4 & t2slo0);
            s[7] = t2shi3 ^ (~t2shi4 & t2shi0);
            s[16] = t2slo8 ^ (~t2slo9 & t2slo5);
            s[17] = t2shi8 ^ (~t2shi9 & t2shi5);
            s[26] = t2slo13 ^ (~t2slo14 & t2slo10);
            s[27] = t2shi13 ^ (~t2shi14 & t2shi10);
            s[36] = t2slo18 ^ (~t2slo19 & t2slo15);
            s[37] = t2shi18 ^ (~t2shi19 & t2shi15);
            s[46] = t2slo23 ^ (~t2slo24 & t2slo20);
            s[47] = t2shi23 ^ (~t2shi24 & t2shi20);
            s[8] = t2slo4 ^ (~t2slo0 & t2slo1);
            s[9] = t2shi4 ^ (~t2shi0 & t2shi1);
            s[18] = t2slo9 ^ (~t2slo5 & t2slo6);
            s[19] = t2shi9 ^ (~t2shi5 & t2shi6);
            s[28] = t2slo14 ^ (~t2slo10 & t2slo11);
            s[29] = t2shi14 ^ (~t2shi10 & t2shi11);
            s[38] = t2slo19 ^ (~t2slo15 & t2slo16);
            s[39] = t2shi19 ^ (~t2shi15 & t2shi16);
            s[48] = t2slo24 ^ (~t2slo20 & t2slo21);
            s[49] = t2shi24 ^ (~t2shi20 & t2shi21);
            s[0] ^= P1600_ROUND_CONSTANTS[round * 2];
            s[1] ^= P1600_ROUND_CONSTANTS[round * 2 + 1];
          }
        };
      },
      {},
    ],
    102: [
      function (require, module, exports) {
        (function (Buffer) {
          (function () {
            const keccakState = require("./keccak-state-unroll");
            function Keccak() {
              this.state = [
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0,
              ];
              this.blockSize = null;
              this.count = 0;
              this.squeezing = false;
            }
            Keccak.prototype.initialize = function (rate, capacity) {
              for (let i = 0; i < 50; ++i) this.state[i] = 0;
              this.blockSize = rate / 8;
              this.count = 0;
              this.squeezing = false;
            };
            Keccak.prototype.absorb = function (data) {
              for (let i = 0; i < data.length; ++i) {
                this.state[~~(this.count / 4)] ^=
                  data[i] << (8 * (this.count % 4));
                this.count += 1;
                if (this.count === this.blockSize) {
                  keccakState.p1600(this.state);
                  this.count = 0;
                }
              }
            };
            Keccak.prototype.absorbLastFewBits = function (bits) {
              this.state[~~(this.count / 4)] ^= bits << (8 * (this.count % 4));
              if ((bits & 128) !== 0 && this.count === this.blockSize - 1)
                keccakState.p1600(this.state);
              this.state[~~((this.blockSize - 1) / 4)] ^=
                128 << (8 * ((this.blockSize - 1) % 4));
              keccakState.p1600(this.state);
              this.count = 0;
              this.squeezing = true;
            };
            Keccak.prototype.squeeze = function (length) {
              if (!this.squeezing) this.absorbLastFewBits(1);
              const output = Buffer.alloc(length);
              for (let i = 0; i < length; ++i) {
                output[i] =
                  (this.state[~~(this.count / 4)] >>> (8 * (this.count % 4))) &
                  255;
                this.count += 1;
                if (this.count === this.blockSize) {
                  keccakState.p1600(this.state);
                  this.count = 0;
                }
              }
              return output;
            };
            Keccak.prototype.copy = function (dest) {
              for (let i = 0; i < 50; ++i) dest.state[i] = this.state[i];
              dest.blockSize = this.blockSize;
              dest.count = this.count;
              dest.squeezing = this.squeezing;
            };
            module.exports = Keccak;
          }).call(this);
        }).call(this, require("buffer").Buffer);
      },
      { "./keccak-state-unroll": 101, buffer: 25 },
    ],
    103: [
      function (require, module, exports) {
        arguments[4][65][0].apply(exports, arguments);
      },
      { dup: 65 },
    ],
    104: [
      function (require, module, exports) {
        arguments[4][66][0].apply(exports, arguments);
      },
      {
        "./_stream_readable": 106,
        "./_stream_writable": 108,
        _process: 122,
        dup: 66,
        inherits: 94,
      },
    ],
    105: [
      function (require, module, exports) {
        arguments[4][67][0].apply(exports, arguments);
      },
      { "./_stream_transform": 107, dup: 67, inherits: 94 },
    ],
    106: [
      function (require, module, exports) {
        arguments[4][68][0].apply(exports, arguments);
      },
      {
        "../errors": 103,
        "./_stream_duplex": 104,
        "./internal/streams/async_iterator": 109,
        "./internal/streams/buffer_list": 110,
        "./internal/streams/destroy": 111,
        "./internal/streams/from": 113,
        "./internal/streams/state": 115,
        "./internal/streams/stream": 116,
        _process: 122,
        buffer: 25,
        dup: 68,
        events: 63,
        inherits: 94,
        "string_decoder/": 153,
        util: 24,
      },
    ],
    107: [
      function (require, module, exports) {
        arguments[4][69][0].apply(exports, arguments);
      },
      { "../errors": 103, "./_stream_duplex": 104, dup: 69, inherits: 94 },
    ],
    108: [
      function (require, module, exports) {
        arguments[4][70][0].apply(exports, arguments);
      },
      {
        "../errors": 103,
        "./_stream_duplex": 104,
        "./internal/streams/destroy": 111,
        "./internal/streams/state": 115,
        "./internal/streams/stream": 116,
        _process: 122,
        buffer: 25,
        dup: 70,
        inherits: 94,
        "util-deprecate": 157,
      },
    ],
    109: [
      function (require, module, exports) {
        arguments[4][71][0].apply(exports, arguments);
      },
      { "./end-of-stream": 112, _process: 122, dup: 71 },
    ],
    110: [
      function (require, module, exports) {
        arguments[4][72][0].apply(exports, arguments);
      },
      { buffer: 25, dup: 72, util: 24 },
    ],
    111: [
      function (require, module, exports) {
        arguments[4][73][0].apply(exports, arguments);
      },
      { _process: 122, dup: 73 },
    ],
    112: [
      function (require, module, exports) {
        arguments[4][74][0].apply(exports, arguments);
      },
      { "../../../errors": 103, dup: 74 },
    ],
    113: [
      function (require, module, exports) {
        arguments[4][75][0].apply(exports, arguments);
      },
      { dup: 75 },
    ],
    114: [
      function (require, module, exports) {
        arguments[4][76][0].apply(exports, arguments);
      },
      { "../../../errors": 103, "./end-of-stream": 112, dup: 76 },
    ],
    115: [
      function (require, module, exports) {
        arguments[4][77][0].apply(exports, arguments);
      },
      { "../../../errors": 103, dup: 77 },
    ],
    116: [
      function (require, module, exports) {
        arguments[4][78][0].apply(exports, arguments);
      },
      { dup: 78, events: 63 },
    ],
    117: [
      function (require, module, exports) {
        arguments[4][79][0].apply(exports, arguments);
      },
      {
        "./lib/_stream_duplex.js": 104,
        "./lib/_stream_passthrough.js": 105,
        "./lib/_stream_readable.js": 106,
        "./lib/_stream_transform.js": 107,
        "./lib/_stream_writable.js": 108,
        "./lib/internal/streams/end-of-stream.js": 112,
        "./lib/internal/streams/pipeline.js": 114,
        dup: 79,
      },
    ],
    118: [
      function (require, module, exports) {
        "use strict";
        var inherits = require("inherits");
        var HashBase = require("hash-base");
        var Buffer = require("safe-buffer").Buffer;
        var ARRAY16 = new Array(16);
        function MD5() {
          HashBase.call(this, 64);
          this._a = 1732584193;
          this._b = 4023233417;
          this._c = 2562383102;
          this._d = 271733878;
        }
        inherits(MD5, HashBase);
        MD5.prototype._update = function () {
          var M = ARRAY16;
          for (var i = 0; i < 16; ++i) M[i] = this._block.readInt32LE(i * 4);
          var a = this._a;
          var b = this._b;
          var c = this._c;
          var d = this._d;
          a = fnF(a, b, c, d, M[0], 3614090360, 7);
          d = fnF(d, a, b, c, M[1], 3905402710, 12);
          c = fnF(c, d, a, b, M[2], 606105819, 17);
          b = fnF(b, c, d, a, M[3], 3250441966, 22);
          a = fnF(a, b, c, d, M[4], 4118548399, 7);
          d = fnF(d, a, b, c, M[5], 1200080426, 12);
          c = fnF(c, d, a, b, M[6], 2821735955, 17);
          b = fnF(b, c, d, a, M[7], 4249261313, 22);
          a = fnF(a, b, c, d, M[8], 1770035416, 7);
          d = fnF(d, a, b, c, M[9], 2336552879, 12);
          c = fnF(c, d, a, b, M[10], 4294925233, 17);
          b = fnF(b, c, d, a, M[11], 2304563134, 22);
          a = fnF(a, b, c, d, M[12], 1804603682, 7);
          d = fnF(d, a, b, c, M[13], 4254626195, 12);
          c = fnF(c, d, a, b, M[14], 2792965006, 17);
          b = fnF(b, c, d, a, M[15], 1236535329, 22);
          a = fnG(a, b, c, d, M[1], 4129170786, 5);
          d = fnG(d, a, b, c, M[6], 3225465664, 9);
          c = fnG(c, d, a, b, M[11], 643717713, 14);
          b = fnG(b, c, d, a, M[0], 3921069994, 20);
          a = fnG(a, b, c, d, M[5], 3593408605, 5);
          d = fnG(d, a, b, c, M[10], 38016083, 9);
          c = fnG(c, d, a, b, M[15], 3634488961, 14);
          b = fnG(b, c, d, a, M[4], 3889429448, 20);
          a = fnG(a, b, c, d, M[9], 568446438, 5);
          d = fnG(d, a, b, c, M[14], 3275163606, 9);
          c = fnG(c, d, a, b, M[3], 4107603335, 14);
          b = fnG(b, c, d, a, M[8], 1163531501, 20);
          a = fnG(a, b, c, d, M[13], 2850285829, 5);
          d = fnG(d, a, b, c, M[2], 4243563512, 9);
          c = fnG(c, d, a, b, M[7], 1735328473, 14);
          b = fnG(b, c, d, a, M[12], 2368359562, 20);
          a = fnH(a, b, c, d, M[5], 4294588738, 4);
          d = fnH(d, a, b, c, M[8], 2272392833, 11);
          c = fnH(c, d, a, b, M[11], 1839030562, 16);
          b = fnH(b, c, d, a, M[14], 4259657740, 23);
          a = fnH(a, b, c, d, M[1], 2763975236, 4);
          d = fnH(d, a, b, c, M[4], 1272893353, 11);
          c = fnH(c, d, a, b, M[7], 4139469664, 16);
          b = fnH(b, c, d, a, M[10], 3200236656, 23);
          a = fnH(a, b, c, d, M[13], 681279174, 4);
          d = fnH(d, a, b, c, M[0], 3936430074, 11);
          c = fnH(c, d, a, b, M[3], 3572445317, 16);
          b = fnH(b, c, d, a, M[6], 76029189, 23);
          a = fnH(a, b, c, d, M[9], 3654602809, 4);
          d = fnH(d, a, b, c, M[12], 3873151461, 11);
          c = fnH(c, d, a, b, M[15], 530742520, 16);
          b = fnH(b, c, d, a, M[2], 3299628645, 23);
          a = fnI(a, b, c, d, M[0], 4096336452, 6);
          d = fnI(d, a, b, c, M[7], 1126891415, 10);
          c = fnI(c, d, a, b, M[14], 2878612391, 15);
          b = fnI(b, c, d, a, M[5], 4237533241, 21);
          a = fnI(a, b, c, d, M[12], 1700485571, 6);
          d = fnI(d, a, b, c, M[3], 2399980690, 10);
          c = fnI(c, d, a, b, M[10], 4293915773, 15);
          b = fnI(b, c, d, a, M[1], 2240044497, 21);
          a = fnI(a, b, c, d, M[8], 1873313359, 6);
          d = fnI(d, a, b, c, M[15], 4264355552, 10);
          c = fnI(c, d, a, b, M[6], 2734768916, 15);
          b = fnI(b, c, d, a, M[13], 1309151649, 21);
          a = fnI(a, b, c, d, M[4], 4149444226, 6);
          d = fnI(d, a, b, c, M[11], 3174756917, 10);
          c = fnI(c, d, a, b, M[2], 718787259, 15);
          b = fnI(b, c, d, a, M[9], 3951481745, 21);
          this._a = (this._a + a) | 0;
          this._b = (this._b + b) | 0;
          this._c = (this._c + c) | 0;
          this._d = (this._d + d) | 0;
        };
        MD5.prototype._digest = function () {
          this._block[this._blockOffset++] = 128;
          if (this._blockOffset > 56) {
            this._block.fill(0, this._blockOffset, 64);
            this._update();
            this._blockOffset = 0;
          }
          this._block.fill(0, this._blockOffset, 56);
          this._block.writeUInt32LE(this._length[0], 56);
          this._block.writeUInt32LE(this._length[1], 60);
          this._update();
          var buffer = Buffer.allocUnsafe(16);
          buffer.writeInt32LE(this._a, 0);
          buffer.writeInt32LE(this._b, 4);
          buffer.writeInt32LE(this._c, 8);
          buffer.writeInt32LE(this._d, 12);
          return buffer;
        };
        function rotl(x, n) {
          return (x << n) | (x >>> (32 - n));
        }
        function fnF(a, b, c, d, m, k, s) {
          return (rotl((a + ((b & c) | (~b & d)) + m + k) | 0, s) + b) | 0;
        }
        function fnG(a, b, c, d, m, k, s) {
          return (rotl((a + ((b & d) | (c & ~d)) + m + k) | 0, s) + b) | 0;
        }
        function fnH(a, b, c, d, m, k, s) {
          return (rotl((a + (b ^ c ^ d) + m + k) | 0, s) + b) | 0;
        }
        function fnI(a, b, c, d, m, k, s) {
          return (rotl((a + (c ^ (b | ~d)) + m + k) | 0, s) + b) | 0;
        }
        module.exports = MD5;
      },
      { "hash-base": 64, inherits: 94, "safe-buffer": 126 },
    ],
    119: [
      function (require, module, exports) {
        module.exports = assert;
        function assert(val, msg) {
          if (!val) throw new Error(msg || "Assertion failed");
        }
        assert.equal = function assertEqual(l, r, msg) {
          if (l != r)
            throw new Error(msg || "Assertion failed: " + l + " != " + r);
        };
      },
      {},
    ],
    120: [
      function (require, module, exports) {
        "use strict";
        var utils = exports;
        function toArray(msg, enc) {
          if (Array.isArray(msg)) return msg.slice();
          if (!msg) return [];
          var res = [];
          if (typeof msg !== "string") {
            for (var i = 0; i < msg.length; i++) res[i] = msg[i] | 0;
            return res;
          }
          if (enc === "hex") {
            msg = msg.replace(/[^a-z0-9]+/gi, "");
            if (msg.length % 2 !== 0) msg = "0" + msg;
            for (var i = 0; i < msg.length; i += 2)
              res.push(parseInt(msg[i] + msg[i + 1], 16));
          } else {
            for (var i = 0; i < msg.length; i++) {
              var c = msg.charCodeAt(i);
              var hi = c >> 8;
              var lo = c & 255;
              if (hi) res.push(hi, lo);
              else res.push(lo);
            }
          }
          return res;
        }
        utils.toArray = toArray;
        function zero2(word) {
          if (word.length === 1) return "0" + word;
          else return word;
        }
        utils.zero2 = zero2;
        function toHex(msg) {
          var res = "";
          for (var i = 0; i < msg.length; i++)
            res += zero2(msg[i].toString(16));
          return res;
        }
        utils.toHex = toHex;
        utils.encode = function encode(arr, enc) {
          if (enc === "hex") return toHex(arr);
          else return arr;
        };
      },
      {},
    ],
    121: [
      function (require, module, exports) {
        "use strict";
        var getOwnPropertySymbols = Object.getOwnPropertySymbols;
        var hasOwnProperty = Object.prototype.hasOwnProperty;
        var propIsEnumerable = Object.prototype.propertyIsEnumerable;
        function toObject(val) {
          if (val === null || val === undefined) {
            throw new TypeError(
              "Object.assign cannot be called with null or undefined"
            );
          }
          return Object(val);
        }
        function shouldUseNative() {
          try {
            if (!Object.assign) {
              return false;
            }
            var test1 = new String("abc");
            test1[5] = "de";
            if (Object.getOwnPropertyNames(test1)[0] === "5") {
              return false;
            }
            var test2 = {};
            for (var i = 0; i < 10; i++) {
              test2["_" + String.fromCharCode(i)] = i;
            }
            var order2 = Object.getOwnPropertyNames(test2).map(function (n) {
              return test2[n];
            });
            if (order2.join("") !== "0123456789") {
              return false;
            }
            var test3 = {};
            "abcdefghijklmnopqrst".split("").forEach(function (letter) {
              test3[letter] = letter;
            });
            if (
              Object.keys(Object.assign({}, test3)).join("") !==
              "abcdefghijklmnopqrst"
            ) {
              return false;
            }
            return true;
          } catch (err) {
            return false;
          }
        }
        module.exports = shouldUseNative()
          ? Object.assign
          : function (target, source) {
              var from;
              var to = toObject(target);
              var symbols;
              for (var s = 1; s < arguments.length; s++) {
                from = Object(arguments[s]);
                for (var key in from) {
                  if (hasOwnProperty.call(from, key)) {
                    to[key] = from[key];
                  }
                }
                if (getOwnPropertySymbols) {
                  symbols = getOwnPropertySymbols(from);
                  for (var i = 0; i < symbols.length; i++) {
                    if (propIsEnumerable.call(from, symbols[i])) {
                      to[symbols[i]] = from[symbols[i]];
                    }
                  }
                }
              }
              return to;
            };
      },
      {},
    ],
    122: [
      function (require, module, exports) {
        var process = (module.exports = {});
        var cachedSetTimeout;
        var cachedClearTimeout;
        function defaultSetTimout() {
          throw new Error("setTimeout has not been defined");
        }
        function defaultClearTimeout() {
          throw new Error("clearTimeout has not been defined");
        }
        (function () {
          try {
            if (typeof setTimeout === "function") {
              cachedSetTimeout = setTimeout;
            } else {
              cachedSetTimeout = defaultSetTimout;
            }
          } catch (e) {
            cachedSetTimeout = defaultSetTimout;
          }
          try {
            if (typeof clearTimeout === "function") {
              cachedClearTimeout = clearTimeout;
            } else {
              cachedClearTimeout = defaultClearTimeout;
            }
          } catch (e) {
            cachedClearTimeout = defaultClearTimeout;
          }
        })();
        function runTimeout(fun) {
          if (cachedSetTimeout === setTimeout) {
            return setTimeout(fun, 0);
          }
          if (
            (cachedSetTimeout === defaultSetTimout || !cachedSetTimeout) &&
            setTimeout
          ) {
            cachedSetTimeout = setTimeout;
            return setTimeout(fun, 0);
          }
          try {
            return cachedSetTimeout(fun, 0);
          } catch (e) {
            try {
              return cachedSetTimeout.call(null, fun, 0);
            } catch (e) {
              return cachedSetTimeout.call(this, fun, 0);
            }
          }
        }
        function runClearTimeout(marker) {
          if (cachedClearTimeout === clearTimeout) {
            return clearTimeout(marker);
          }
          if (
            (cachedClearTimeout === defaultClearTimeout ||
              !cachedClearTimeout) &&
            clearTimeout
          ) {
            cachedClearTimeout = clearTimeout;
            return clearTimeout(marker);
          }
          try {
            return cachedClearTimeout(marker);
          } catch (e) {
            try {
              return cachedClearTimeout.call(null, marker);
            } catch (e) {
              return cachedClearTimeout.call(this, marker);
            }
          }
        }
        var queue = [];
        var draining = false;
        var currentQueue;
        var queueIndex = -1;
        function cleanUpNextTick() {
          if (!draining || !currentQueue) {
            return;
          }
          draining = false;
          if (currentQueue.length) {
            queue = currentQueue.concat(queue);
          } else {
            queueIndex = -1;
          }
          if (queue.length) {
            drainQueue();
          }
        }
        function drainQueue() {
          if (draining) {
            return;
          }
          var timeout = runTimeout(cleanUpNextTick);
          draining = true;
          var len = queue.length;
          while (len) {
            currentQueue = queue;
            queue = [];
            while (++queueIndex < len) {
              if (currentQueue) {
                currentQueue[queueIndex].run();
              }
            }
            queueIndex = -1;
            len = queue.length;
          }
          currentQueue = null;
          draining = false;
          runClearTimeout(timeout);
        }
        process.nextTick = function (fun) {
          var args = new Array(arguments.length - 1);
          if (arguments.length > 1) {
            for (var i = 1; i < arguments.length; i++) {
              args[i - 1] = arguments[i];
            }
          }
          queue.push(new Item(fun, args));
          if (queue.length === 1 && !draining) {
            runTimeout(drainQueue);
          }
        };
        function Item(fun, array) {
          this.fun = fun;
          this.array = array;
        }
        Item.prototype.run = function () {
          this.fun.apply(null, this.array);
        };
        process.title = "browser";
        process.browser = true;
        process.env = {};
        process.argv = [];
        process.version = "";
        process.versions = {};
        function noop() {}
        process.on = noop;
        process.addListener = noop;
        process.once = noop;
        process.off = noop;
        process.removeListener = noop;
        process.removeAllListeners = noop;
        process.emit = noop;
        process.prependListener = noop;
        process.prependOnceListener = noop;
        process.listeners = function (name) {
          return [];
        };
        process.binding = function (name) {
          throw new Error("process.binding is not supported");
        };
        process.cwd = function () {
          return "/";
        };
        process.chdir = function (dir) {
          throw new Error("process.chdir is not supported");
        };
        process.umask = function () {
          return 0;
        };
      },
      {},
    ],
    123: [
      function (require, module, exports) {
        (function (process, global) {
          (function () {
            "use strict";
            var MAX_BYTES = 65536;
            var MAX_UINT32 = 4294967295;
            function oldBrowser() {
              throw new Error(
                "Secure random number generation is not supported by this browser.\nUse Chrome, Firefox or Internet Explorer 11"
              );
            }
            var Buffer = require("safe-buffer").Buffer;
            var crypto = global.crypto || global.msCrypto;
            if (crypto && crypto.getRandomValues) {
              module.exports = randomBytes;
            } else {
              module.exports = oldBrowser;
            }
            function randomBytes(size, cb) {
              if (size > MAX_UINT32)
                throw new RangeError("requested too many random bytes");
              var bytes = Buffer.allocUnsafe(size);
              if (size > 0) {
                if (size > MAX_BYTES) {
                  for (
                    var generated = 0;
                    generated < size;
                    generated += MAX_BYTES
                  ) {
                    crypto.getRandomValues(
                      bytes.slice(generated, generated + MAX_BYTES)
                    );
                  }
                } else {
                  crypto.getRandomValues(bytes);
                }
              }
              if (typeof cb === "function") {
                return process.nextTick(function () {
                  cb(null, bytes);
                });
              }
              return bytes;
            }
          }).call(this);
        }).call(
          this,
          require("_process"),
          typeof global !== "undefined"
            ? global
            : typeof self !== "undefined"
            ? self
            : typeof window !== "undefined"
            ? window
            : {}
        );
      },
      { _process: 122, "safe-buffer": 126 },
    ],
    124: [
      function (require, module, exports) {
        "use strict";
        var Buffer = require("buffer").Buffer;
        var inherits = require("inherits");
        var HashBase = require("hash-base");
        var ARRAY16 = new Array(16);
        var zl = [
          0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 7, 4, 13, 1, 10,
          6, 15, 3, 12, 0, 9, 5, 2, 14, 11, 8, 3, 10, 14, 4, 9, 15, 8, 1, 2, 7,
          0, 6, 13, 11, 5, 12, 1, 9, 11, 10, 0, 8, 12, 4, 13, 3, 7, 15, 14, 5,
          6, 2, 4, 0, 5, 9, 7, 12, 2, 10, 14, 1, 3, 8, 11, 6, 15, 13,
        ];
        var zr = [
          5, 14, 7, 0, 9, 2, 11, 4, 13, 6, 15, 8, 1, 10, 3, 12, 6, 11, 3, 7, 0,
          13, 5, 10, 14, 15, 8, 12, 4, 9, 1, 2, 15, 5, 1, 3, 7, 14, 6, 9, 11, 8,
          12, 2, 10, 0, 4, 13, 8, 6, 4, 1, 3, 11, 15, 0, 5, 12, 2, 13, 9, 7, 10,
          14, 12, 15, 10, 4, 1, 5, 8, 7, 6, 2, 13, 14, 0, 3, 9, 11,
        ];
        var sl = [
          11, 14, 15, 12, 5, 8, 7, 9, 11, 13, 14, 15, 6, 7, 9, 8, 7, 6, 8, 13,
          11, 9, 7, 15, 7, 12, 15, 9, 11, 7, 13, 12, 11, 13, 6, 7, 14, 9, 13,
          15, 14, 8, 13, 6, 5, 12, 7, 5, 11, 12, 14, 15, 14, 15, 9, 8, 9, 14, 5,
          6, 8, 6, 5, 12, 9, 15, 5, 11, 6, 8, 13, 12, 5, 12, 13, 14, 11, 8, 5,
          6,
        ];
        var sr = [
          8, 9, 9, 11, 13, 15, 15, 5, 7, 7, 8, 11, 14, 14, 12, 6, 9, 13, 15, 7,
          12, 8, 9, 11, 7, 7, 12, 7, 6, 15, 13, 11, 9, 7, 15, 11, 8, 6, 6, 14,
          12, 13, 5, 14, 13, 13, 7, 5, 15, 5, 8, 11, 14, 14, 6, 14, 6, 9, 12, 9,
          12, 5, 15, 8, 8, 5, 12, 9, 12, 5, 14, 6, 8, 13, 6, 5, 15, 13, 11, 11,
        ];
        var hl = [0, 1518500249, 1859775393, 2400959708, 2840853838];
        var hr = [1352829926, 1548603684, 1836072691, 2053994217, 0];
        function RIPEMD160() {
          HashBase.call(this, 64);
          this._a = 1732584193;
          this._b = 4023233417;
          this._c = 2562383102;
          this._d = 271733878;
          this._e = 3285377520;
        }
        inherits(RIPEMD160, HashBase);
        RIPEMD160.prototype._update = function () {
          var words = ARRAY16;
          for (var j = 0; j < 16; ++j)
            words[j] = this._block.readInt32LE(j * 4);
          var al = this._a | 0;
          var bl = this._b | 0;
          var cl = this._c | 0;
          var dl = this._d | 0;
          var el = this._e | 0;
          var ar = this._a | 0;
          var br = this._b | 0;
          var cr = this._c | 0;
          var dr = this._d | 0;
          var er = this._e | 0;
          for (var i = 0; i < 80; i += 1) {
            var tl;
            var tr;
            if (i < 16) {
              tl = fn1(al, bl, cl, dl, el, words[zl[i]], hl[0], sl[i]);
              tr = fn5(ar, br, cr, dr, er, words[zr[i]], hr[0], sr[i]);
            } else if (i < 32) {
              tl = fn2(al, bl, cl, dl, el, words[zl[i]], hl[1], sl[i]);
              tr = fn4(ar, br, cr, dr, er, words[zr[i]], hr[1], sr[i]);
            } else if (i < 48) {
              tl = fn3(al, bl, cl, dl, el, words[zl[i]], hl[2], sl[i]);
              tr = fn3(ar, br, cr, dr, er, words[zr[i]], hr[2], sr[i]);
            } else if (i < 64) {
              tl = fn4(al, bl, cl, dl, el, words[zl[i]], hl[3], sl[i]);
              tr = fn2(ar, br, cr, dr, er, words[zr[i]], hr[3], sr[i]);
            } else {
              tl = fn5(al, bl, cl, dl, el, words[zl[i]], hl[4], sl[i]);
              tr = fn1(ar, br, cr, dr, er, words[zr[i]], hr[4], sr[i]);
            }
            al = el;
            el = dl;
            dl = rotl(cl, 10);
            cl = bl;
            bl = tl;
            ar = er;
            er = dr;
            dr = rotl(cr, 10);
            cr = br;
            br = tr;
          }
          var t = (this._b + cl + dr) | 0;
          this._b = (this._c + dl + er) | 0;
          this._c = (this._d + el + ar) | 0;
          this._d = (this._e + al + br) | 0;
          this._e = (this._a + bl + cr) | 0;
          this._a = t;
        };
        RIPEMD160.prototype._digest = function () {
          this._block[this._blockOffset++] = 128;
          if (this._blockOffset > 56) {
            this._block.fill(0, this._blockOffset, 64);
            this._update();
            this._blockOffset = 0;
          }
          this._block.fill(0, this._blockOffset, 56);
          this._block.writeUInt32LE(this._length[0], 56);
          this._block.writeUInt32LE(this._length[1], 60);
          this._update();
          var buffer = Buffer.alloc ? Buffer.alloc(20) : new Buffer(20);
          buffer.writeInt32LE(this._a, 0);
          buffer.writeInt32LE(this._b, 4);
          buffer.writeInt32LE(this._c, 8);
          buffer.writeInt32LE(this._d, 12);
          buffer.writeInt32LE(this._e, 16);
          return buffer;
        };
        function rotl(x, n) {
          return (x << n) | (x >>> (32 - n));
        }
        function fn1(a, b, c, d, e, m, k, s) {
          return (rotl((a + (b ^ c ^ d) + m + k) | 0, s) + e) | 0;
        }
        function fn2(a, b, c, d, e, m, k, s) {
          return (rotl((a + ((b & c) | (~b & d)) + m + k) | 0, s) + e) | 0;
        }
        function fn3(a, b, c, d, e, m, k, s) {
          return (rotl((a + ((b | ~c) ^ d) + m + k) | 0, s) + e) | 0;
        }
        function fn4(a, b, c, d, e, m, k, s) {
          return (rotl((a + ((b & d) | (c & ~d)) + m + k) | 0, s) + e) | 0;
        }
        function fn5(a, b, c, d, e, m, k, s) {
          return (rotl((a + (b ^ (c | ~d)) + m + k) | 0, s) + e) | 0;
        }
        module.exports = RIPEMD160;
      },
      { buffer: 25, "hash-base": 64, inherits: 94 },
    ],
    125: [
      function (require, module, exports) {
        (function (Buffer) {
          (function () {
            "use strict";
            var __importDefault =
              (this && this.__importDefault) ||
              function (mod) {
                return mod && mod.__esModule ? mod : { default: mod };
              };
            Object.defineProperty(exports, "__esModule", { value: true });
            exports.getLength = exports.decode = exports.encode = void 0;
            var bn_js_1 = __importDefault(require("bn.js"));
            function encode(input) {
              if (Array.isArray(input)) {
                var output = [];
                for (var i = 0; i < input.length; i++) {
                  output.push(encode(input[i]));
                }
                var buf = Buffer.concat(output);
                return Buffer.concat([encodeLength(buf.length, 192), buf]);
              } else {
                var inputBuf = toBuffer(input);
                return inputBuf.length === 1 && inputBuf[0] < 128
                  ? inputBuf
                  : Buffer.concat([
                      encodeLength(inputBuf.length, 128),
                      inputBuf,
                    ]);
              }
            }
            exports.encode = encode;
            function safeParseInt(v, base) {
              if (v[0] === "0" && v[1] === "0") {
                throw new Error("invalid RLP: extra zeros");
              }
              return parseInt(v, base);
            }
            function encodeLength(len, offset) {
              if (len < 56) {
                return Buffer.from([len + offset]);
              } else {
                var hexLength = intToHex(len);
                var lLength = hexLength.length / 2;
                var firstByte = intToHex(offset + 55 + lLength);
                return Buffer.from(firstByte + hexLength, "hex");
              }
            }
            function decode(input, stream) {
              if (stream === void 0) {
                stream = false;
              }
              if (!input || input.length === 0) {
                return Buffer.from([]);
              }
              var inputBuffer = toBuffer(input);
              var decoded = _decode(inputBuffer);
              if (stream) {
                return decoded;
              }
              if (decoded.remainder.length !== 0) {
                throw new Error("invalid remainder");
              }
              return decoded.data;
            }
            exports.decode = decode;
            function getLength(input) {
              if (!input || input.length === 0) {
                return Buffer.from([]);
              }
              var inputBuffer = toBuffer(input);
              var firstByte = inputBuffer[0];
              if (firstByte <= 127) {
                return inputBuffer.length;
              } else if (firstByte <= 183) {
                return firstByte - 127;
              } else if (firstByte <= 191) {
                return firstByte - 182;
              } else if (firstByte <= 247) {
                return firstByte - 191;
              } else {
                var llength = firstByte - 246;
                var length_1 = safeParseInt(
                  inputBuffer.slice(1, llength).toString("hex"),
                  16
                );
                return llength + length_1;
              }
            }
            exports.getLength = getLength;
            function _decode(input) {
              var length, llength, data, innerRemainder, d;
              var decoded = [];
              var firstByte = input[0];
              if (firstByte <= 127) {
                return { data: input.slice(0, 1), remainder: input.slice(1) };
              } else if (firstByte <= 183) {
                length = firstByte - 127;
                if (firstByte === 128) {
                  data = Buffer.from([]);
                } else {
                  data = input.slice(1, length);
                }
                if (length === 2 && data[0] < 128) {
                  throw new Error(
                    "invalid rlp encoding: byte must be less 0x80"
                  );
                }
                return { data: data, remainder: input.slice(length) };
              } else if (firstByte <= 191) {
                llength = firstByte - 182;
                if (input.length - 1 < llength) {
                  throw new Error(
                    "invalid RLP: not enough bytes for string length"
                  );
                }
                length = safeParseInt(
                  input.slice(1, llength).toString("hex"),
                  16
                );
                if (length <= 55) {
                  throw new Error(
                    "invalid RLP: expected string length to be greater than 55"
                  );
                }
                data = input.slice(llength, length + llength);
                if (data.length < length) {
                  throw new Error("invalid RLP: not enough bytes for string");
                }
                return { data: data, remainder: input.slice(length + llength) };
              } else if (firstByte <= 247) {
                length = firstByte - 191;
                innerRemainder = input.slice(1, length);
                while (innerRemainder.length) {
                  d = _decode(innerRemainder);
                  decoded.push(d.data);
                  innerRemainder = d.remainder;
                }
                return { data: decoded, remainder: input.slice(length) };
              } else {
                llength = firstByte - 246;
                length = safeParseInt(
                  input.slice(1, llength).toString("hex"),
                  16
                );
                var totalLength = llength + length;
                if (totalLength > input.length) {
                  throw new Error(
                    "invalid rlp: total length is larger than the data"
                  );
                }
                innerRemainder = input.slice(llength, totalLength);
                if (innerRemainder.length === 0) {
                  throw new Error("invalid rlp, List has a invalid length");
                }
                while (innerRemainder.length) {
                  d = _decode(innerRemainder);
                  decoded.push(d.data);
                  innerRemainder = d.remainder;
                }
                return { data: decoded, remainder: input.slice(totalLength) };
              }
            }
            function isHexPrefixed(str) {
              return str.slice(0, 2) === "0x";
            }
            function stripHexPrefix(str) {
              if (typeof str !== "string") {
                return str;
              }
              return isHexPrefixed(str) ? str.slice(2) : str;
            }
            function intToHex(integer) {
              if (integer < 0) {
                throw new Error(
                  "Invalid integer as argument, must be unsigned!"
                );
              }
              var hex = integer.toString(16);
              return hex.length % 2 ? "0" + hex : hex;
            }
            function padToEven(a) {
              return a.length % 2 ? "0" + a : a;
            }
            function intToBuffer(integer) {
              var hex = intToHex(integer);
              return Buffer.from(hex, "hex");
            }
            function toBuffer(v) {
              if (!Buffer.isBuffer(v)) {
                if (typeof v === "string") {
                  if (isHexPrefixed(v)) {
                    return Buffer.from(padToEven(stripHexPrefix(v)), "hex");
                  } else {
                    return Buffer.from(v);
                  }
                } else if (typeof v === "number" || typeof v === "bigint") {
                  if (!v) {
                    return Buffer.from([]);
                  } else {
                    return intToBuffer(v);
                  }
                } else if (v === null || v === undefined) {
                  return Buffer.from([]);
                } else if (v instanceof Uint8Array) {
                  return Buffer.from(v);
                } else if (bn_js_1.default.isBN(v)) {
                  return Buffer.from(v.toArray());
                } else {
                  throw new Error("invalid type");
                }
              }
              return v;
            }
          }).call(this);
        }).call(this, require("buffer").Buffer);
      },
      { "bn.js": 22, buffer: 25 },
    ],
    126: [
      function (require, module, exports) {
        var buffer = require("buffer");
        var Buffer = buffer.Buffer;
        function copyProps(src, dst) {
          for (var key in src) {
            dst[key] = src[key];
          }
        }
        if (
          Buffer.from &&
          Buffer.alloc &&
          Buffer.allocUnsafe &&
          Buffer.allocUnsafeSlow
        ) {
          module.exports = buffer;
        } else {
          copyProps(buffer, exports);
          exports.Buffer = SafeBuffer;
        }
        function SafeBuffer(arg, encodingOrOffset, length) {
          return Buffer(arg, encodingOrOffset, length);
        }
        SafeBuffer.prototype = Object.create(Buffer.prototype);
        copyProps(Buffer, SafeBuffer);
        SafeBuffer.from = function (arg, encodingOrOffset, length) {
          if (typeof arg === "number") {
            throw new TypeError("Argument must not be a number");
          }
          return Buffer(arg, encodingOrOffset, length);
        };
        SafeBuffer.alloc = function (size, fill, encoding) {
          if (typeof size !== "number") {
            throw new TypeError("Argument must be a number");
          }
          var buf = Buffer(size);
          if (fill !== undefined) {
            if (typeof encoding === "string") {
              buf.fill(fill, encoding);
            } else {
              buf.fill(fill);
            }
          } else {
            buf.fill(0);
          }
          return buf;
        };
        SafeBuffer.allocUnsafe = function (size) {
          if (typeof size !== "number") {
            throw new TypeError("Argument must be a number");
          }
          return Buffer(size);
        };
        SafeBuffer.allocUnsafeSlow = function (size) {
          if (typeof size !== "number") {
            throw new TypeError("Argument must be a number");
          }
          return buffer.SlowBuffer(size);
        };
      },
      { buffer: 25 },
    ],
    127: [
      function (require, module, exports) {
        module.exports = require("./lib")(require("./lib/elliptic"));
      },
      { "./lib": 129, "./lib/elliptic": 128 },
    ],
    128: [
      function (require, module, exports) {
        const EC = require("elliptic").ec;
        const ec = new EC("secp256k1");
        const ecparams = ec.curve;
        const BN = ecparams.n.constructor;
        function loadCompressedPublicKey(first, xbuf) {
          let x = new BN(xbuf);
          if (x.cmp(ecparams.p) >= 0) return null;
          x = x.toRed(ecparams.red);
          let y = x.redSqr().redIMul(x).redIAdd(ecparams.b).redSqrt();
          if ((first === 3) !== y.isOdd()) y = y.redNeg();
          return ec.keyPair({ pub: { x: x, y: y } });
        }
        function loadUncompressedPublicKey(first, xbuf, ybuf) {
          let x = new BN(xbuf);
          let y = new BN(ybuf);
          if (x.cmp(ecparams.p) >= 0 || y.cmp(ecparams.p) >= 0) return null;
          x = x.toRed(ecparams.red);
          y = y.toRed(ecparams.red);
          if ((first === 6 || first === 7) && y.isOdd() !== (first === 7))
            return null;
          const x3 = x.redSqr().redIMul(x);
          if (!y.redSqr().redISub(x3.redIAdd(ecparams.b)).isZero()) return null;
          return ec.keyPair({ pub: { x: x, y: y } });
        }
        function loadPublicKey(pubkey) {
          const first = pubkey[0];
          switch (first) {
            case 2:
            case 3:
              if (pubkey.length !== 33) return null;
              return loadCompressedPublicKey(first, pubkey.subarray(1, 33));
            case 4:
            case 6:
            case 7:
              if (pubkey.length !== 65) return null;
              return loadUncompressedPublicKey(
                first,
                pubkey.subarray(1, 33),
                pubkey.subarray(33, 65)
              );
            default:
              return null;
          }
        }
        function savePublicKey(output, point) {
          const pubkey = point.encode(null, output.length === 33);
          for (let i = 0; i < output.length; ++i) output[i] = pubkey[i];
        }
        module.exports = {
          contextRandomize() {
            return 0;
          },
          privateKeyVerify(seckey) {
            const bn = new BN(seckey);
            return bn.cmp(ecparams.n) < 0 && !bn.isZero() ? 0 : 1;
          },
          privateKeyNegate(seckey) {
            const bn = new BN(seckey);
            const negate = ecparams.n
              .sub(bn)
              .umod(ecparams.n)
              .toArrayLike(Uint8Array, "be", 32);
            seckey.set(negate);
            return 0;
          },
          privateKeyTweakAdd(seckey, tweak) {
            const bn = new BN(tweak);
            if (bn.cmp(ecparams.n) >= 0) return 1;
            bn.iadd(new BN(seckey));
            if (bn.cmp(ecparams.n) >= 0) bn.isub(ecparams.n);
            if (bn.isZero()) return 1;
            const tweaked = bn.toArrayLike(Uint8Array, "be", 32);
            seckey.set(tweaked);
            return 0;
          },
          privateKeyTweakMul(seckey, tweak) {
            let bn = new BN(tweak);
            if (bn.cmp(ecparams.n) >= 0 || bn.isZero()) return 1;
            bn.imul(new BN(seckey));
            if (bn.cmp(ecparams.n) >= 0) bn = bn.umod(ecparams.n);
            const tweaked = bn.toArrayLike(Uint8Array, "be", 32);
            seckey.set(tweaked);
            return 0;
          },
          publicKeyVerify(pubkey) {
            const pair = loadPublicKey(pubkey);
            return pair === null ? 1 : 0;
          },
          publicKeyCreate(output, seckey) {
            const bn = new BN(seckey);
            if (bn.cmp(ecparams.n) >= 0 || bn.isZero()) return 1;
            const point = ec.keyFromPrivate(seckey).getPublic();
            savePublicKey(output, point);
            return 0;
          },
          publicKeyConvert(output, pubkey) {
            const pair = loadPublicKey(pubkey);
            if (pair === null) return 1;
            const point = pair.getPublic();
            savePublicKey(output, point);
            return 0;
          },
          publicKeyNegate(output, pubkey) {
            const pair = loadPublicKey(pubkey);
            if (pair === null) return 1;
            const point = pair.getPublic();
            point.y = point.y.redNeg();
            savePublicKey(output, point);
            return 0;
          },
          publicKeyCombine(output, pubkeys) {
            const pairs = new Array(pubkeys.length);
            for (let i = 0; i < pubkeys.length; ++i) {
              pairs[i] = loadPublicKey(pubkeys[i]);
              if (pairs[i] === null) return 1;
            }
            let point = pairs[0].getPublic();
            for (let i = 1; i < pairs.length; ++i)
              point = point.add(pairs[i].pub);
            if (point.isInfinity()) return 2;
            savePublicKey(output, point);
            return 0;
          },
          publicKeyTweakAdd(output, pubkey, tweak) {
            const pair = loadPublicKey(pubkey);
            if (pair === null) return 1;
            tweak = new BN(tweak);
            if (tweak.cmp(ecparams.n) >= 0) return 2;
            const point = pair.getPublic().add(ecparams.g.mul(tweak));
            if (point.isInfinity()) return 2;
            savePublicKey(output, point);
            return 0;
          },
          publicKeyTweakMul(output, pubkey, tweak) {
            const pair = loadPublicKey(pubkey);
            if (pair === null) return 1;
            tweak = new BN(tweak);
            if (tweak.cmp(ecparams.n) >= 0 || tweak.isZero()) return 2;
            const point = pair.getPublic().mul(tweak);
            savePublicKey(output, point);
            return 0;
          },
          signatureNormalize(sig) {
            const r = new BN(sig.subarray(0, 32));
            const s = new BN(sig.subarray(32, 64));
            if (r.cmp(ecparams.n) >= 0 || s.cmp(ecparams.n) >= 0) return 1;
            if (s.cmp(ec.nh) === 1) {
              sig.set(ecparams.n.sub(s).toArrayLike(Uint8Array, "be", 32), 32);
            }
            return 0;
          },
          signatureExport(obj, sig) {
            const sigR = sig.subarray(0, 32);
            const sigS = sig.subarray(32, 64);
            if (new BN(sigR).cmp(ecparams.n) >= 0) return 1;
            if (new BN(sigS).cmp(ecparams.n) >= 0) return 1;
            const { output } = obj;
            let r = output.subarray(4, 4 + 33);
            r[0] = 0;
            r.set(sigR, 1);
            let lenR = 33;
            let posR = 0;
            for (
              ;
              lenR > 1 && r[posR] === 0 && !(r[posR + 1] & 128);
              --lenR, ++posR
            );
            r = r.subarray(posR);
            if (r[0] & 128) return 1;
            if (lenR > 1 && r[0] === 0 && !(r[1] & 128)) return 1;
            let s = output.subarray(6 + 33, 6 + 33 + 33);
            s[0] = 0;
            s.set(sigS, 1);
            let lenS = 33;
            let posS = 0;
            for (
              ;
              lenS > 1 && s[posS] === 0 && !(s[posS + 1] & 128);
              --lenS, ++posS
            );
            s = s.subarray(posS);
            if (s[0] & 128) return 1;
            if (lenS > 1 && s[0] === 0 && !(s[1] & 128)) return 1;
            obj.outputlen = 6 + lenR + lenS;
            output[0] = 48;
            output[1] = obj.outputlen - 2;
            output[2] = 2;
            output[3] = r.length;
            output.set(r, 4);
            output[4 + lenR] = 2;
            output[5 + lenR] = s.length;
            output.set(s, 6 + lenR);
            return 0;
          },
          signatureImport(output, sig) {
            if (sig.length < 8) return 1;
            if (sig.length > 72) return 1;
            if (sig[0] !== 48) return 1;
            if (sig[1] !== sig.length - 2) return 1;
            if (sig[2] !== 2) return 1;
            const lenR = sig[3];
            if (lenR === 0) return 1;
            if (5 + lenR >= sig.length) return 1;
            if (sig[4 + lenR] !== 2) return 1;
            const lenS = sig[5 + lenR];
            if (lenS === 0) return 1;
            if (6 + lenR + lenS !== sig.length) return 1;
            if (sig[4] & 128) return 1;
            if (lenR > 1 && sig[4] === 0 && !(sig[5] & 128)) return 1;
            if (sig[lenR + 6] & 128) return 1;
            if (lenS > 1 && sig[lenR + 6] === 0 && !(sig[lenR + 7] & 128))
              return 1;
            let sigR = sig.subarray(4, 4 + lenR);
            if (sigR.length === 33 && sigR[0] === 0) sigR = sigR.subarray(1);
            if (sigR.length > 32) return 1;
            let sigS = sig.subarray(6 + lenR);
            if (sigS.length === 33 && sigS[0] === 0) sigS = sigS.slice(1);
            if (sigS.length > 32) throw new Error("S length is too long");
            let r = new BN(sigR);
            if (r.cmp(ecparams.n) >= 0) r = new BN(0);
            let s = new BN(sig.subarray(6 + lenR));
            if (s.cmp(ecparams.n) >= 0) s = new BN(0);
            output.set(r.toArrayLike(Uint8Array, "be", 32), 0);
            output.set(s.toArrayLike(Uint8Array, "be", 32), 32);
            return 0;
          },
          ecdsaSign(obj, message, seckey, data, noncefn) {
            if (noncefn) {
              const _noncefn = noncefn;
              noncefn = (counter) => {
                const nonce = _noncefn(message, seckey, null, data, counter);
                const isValid =
                  nonce instanceof Uint8Array && nonce.length === 32;
                if (!isValid) throw new Error("This is the way");
                return new BN(nonce);
              };
            }
            const d = new BN(seckey);
            if (d.cmp(ecparams.n) >= 0 || d.isZero()) return 1;
            let sig;
            try {
              sig = ec.sign(message, seckey, {
                canonical: true,
                k: noncefn,
                pers: data,
              });
            } catch (err) {
              return 1;
            }
            obj.signature.set(sig.r.toArrayLike(Uint8Array, "be", 32), 0);
            obj.signature.set(sig.s.toArrayLike(Uint8Array, "be", 32), 32);
            obj.recid = sig.recoveryParam;
            return 0;
          },
          ecdsaVerify(sig, msg32, pubkey) {
            const sigObj = { r: sig.subarray(0, 32), s: sig.subarray(32, 64) };
            const sigr = new BN(sigObj.r);
            const sigs = new BN(sigObj.s);
            if (sigr.cmp(ecparams.n) >= 0 || sigs.cmp(ecparams.n) >= 0)
              return 1;
            if (sigs.cmp(ec.nh) === 1 || sigr.isZero() || sigs.isZero())
              return 3;
            const pair = loadPublicKey(pubkey);
            if (pair === null) return 2;
            const point = pair.getPublic();
            const isValid = ec.verify(msg32, sigObj, point);
            return isValid ? 0 : 3;
          },
          ecdsaRecover(output, sig, recid, msg32) {
            const sigObj = { r: sig.slice(0, 32), s: sig.slice(32, 64) };
            const sigr = new BN(sigObj.r);
            const sigs = new BN(sigObj.s);
            if (sigr.cmp(ecparams.n) >= 0 || sigs.cmp(ecparams.n) >= 0)
              return 1;
            if (sigr.isZero() || sigs.isZero()) return 2;
            let point;
            try {
              point = ec.recoverPubKey(msg32, sigObj, recid);
            } catch (err) {
              return 2;
            }
            savePublicKey(output, point);
            return 0;
          },
          ecdh(output, pubkey, seckey, data, hashfn, xbuf, ybuf) {
            const pair = loadPublicKey(pubkey);
            if (pair === null) return 1;
            const scalar = new BN(seckey);
            if (scalar.cmp(ecparams.n) >= 0 || scalar.isZero()) return 2;
            const point = pair.getPublic().mul(scalar);
            if (hashfn === undefined) {
              const data = point.encode(null, true);
              const sha256 = ec.hash().update(data).digest();
              for (let i = 0; i < 32; ++i) output[i] = sha256[i];
            } else {
              if (!xbuf) xbuf = new Uint8Array(32);
              const x = point.getX().toArray("be", 32);
              for (let i = 0; i < 32; ++i) xbuf[i] = x[i];
              if (!ybuf) ybuf = new Uint8Array(32);
              const y = point.getY().toArray("be", 32);
              for (let i = 0; i < 32; ++i) ybuf[i] = y[i];
              const hash = hashfn(xbuf, ybuf, data);
              const isValid =
                hash instanceof Uint8Array && hash.length === output.length;
              if (!isValid) return 2;
              output.set(hash);
            }
            return 0;
          },
        };
      },
      { elliptic: 28 },
    ],
    129: [
      function (require, module, exports) {
        const errors = {
          IMPOSSIBLE_CASE: "Impossible case. Please create issue.",
          TWEAK_ADD:
            "The tweak was out of range or the resulted private key is invalid",
          TWEAK_MUL: "The tweak was out of range or equal to zero",
          CONTEXT_RANDOMIZE_UNKNOW: "Unknow error on context randomization",
          SECKEY_INVALID: "Private Key is invalid",
          PUBKEY_PARSE: "Public Key could not be parsed",
          PUBKEY_SERIALIZE: "Public Key serialization error",
          PUBKEY_COMBINE: "The sum of the public keys is not valid",
          SIG_PARSE: "Signature could not be parsed",
          SIGN: "The nonce generation function failed, or the private key was invalid",
          RECOVER: "Public key could not be recover",
          ECDH: "Scalar was invalid (zero or overflow)",
        };
        function assert(cond, msg) {
          if (!cond) throw new Error(msg);
        }
        function isUint8Array(name, value, length) {
          assert(
            value instanceof Uint8Array,
            `Expected ${name} to be an Uint8Array`
          );
          if (length !== undefined) {
            if (Array.isArray(length)) {
              const numbers = length.join(", ");
              const msg = `Expected ${name} to be an Uint8Array with length [${numbers}]`;
              assert(length.includes(value.length), msg);
            } else {
              const msg = `Expected ${name} to be an Uint8Array with length ${length}`;
              assert(value.length === length, msg);
            }
          }
        }
        function isCompressed(value) {
          assert(
            toTypeString(value) === "Boolean",
            "Expected compressed to be a Boolean"
          );
        }
        function getAssertedOutput(
          output = (len) => new Uint8Array(len),
          length
        ) {
          if (typeof output === "function") output = output(length);
          isUint8Array("output", output, length);
          return output;
        }
        function toTypeString(value) {
          return Object.prototype.toString.call(value).slice(8, -1);
        }
        module.exports = (secp256k1) => {
          return {
            contextRandomize(seed) {
              assert(
                seed === null || seed instanceof Uint8Array,
                "Expected seed to be an Uint8Array or null"
              );
              if (seed !== null) isUint8Array("seed", seed, 32);
              switch (secp256k1.contextRandomize(seed)) {
                case 1:
                  throw new Error(errors.CONTEXT_RANDOMIZE_UNKNOW);
              }
            },
            privateKeyVerify(seckey) {
              isUint8Array("private key", seckey, 32);
              return secp256k1.privateKeyVerify(seckey) === 0;
            },
            privateKeyNegate(seckey) {
              isUint8Array("private key", seckey, 32);
              switch (secp256k1.privateKeyNegate(seckey)) {
                case 0:
                  return seckey;
                case 1:
                  throw new Error(errors.IMPOSSIBLE_CASE);
              }
            },
            privateKeyTweakAdd(seckey, tweak) {
              isUint8Array("private key", seckey, 32);
              isUint8Array("tweak", tweak, 32);
              switch (secp256k1.privateKeyTweakAdd(seckey, tweak)) {
                case 0:
                  return seckey;
                case 1:
                  throw new Error(errors.TWEAK_ADD);
              }
            },
            privateKeyTweakMul(seckey, tweak) {
              isUint8Array("private key", seckey, 32);
              isUint8Array("tweak", tweak, 32);
              switch (secp256k1.privateKeyTweakMul(seckey, tweak)) {
                case 0:
                  return seckey;
                case 1:
                  throw new Error(errors.TWEAK_MUL);
              }
            },
            publicKeyVerify(pubkey) {
              isUint8Array("public key", pubkey, [33, 65]);
              return secp256k1.publicKeyVerify(pubkey) === 0;
            },
            publicKeyCreate(seckey, compressed = true, output) {
              isUint8Array("private key", seckey, 32);
              isCompressed(compressed);
              output = getAssertedOutput(output, compressed ? 33 : 65);
              switch (secp256k1.publicKeyCreate(output, seckey)) {
                case 0:
                  return output;
                case 1:
                  throw new Error(errors.SECKEY_INVALID);
                case 2:
                  throw new Error(errors.PUBKEY_SERIALIZE);
              }
            },
            publicKeyConvert(pubkey, compressed = true, output) {
              isUint8Array("public key", pubkey, [33, 65]);
              isCompressed(compressed);
              output = getAssertedOutput(output, compressed ? 33 : 65);
              switch (secp256k1.publicKeyConvert(output, pubkey)) {
                case 0:
                  return output;
                case 1:
                  throw new Error(errors.PUBKEY_PARSE);
                case 2:
                  throw new Error(errors.PUBKEY_SERIALIZE);
              }
            },
            publicKeyNegate(pubkey, compressed = true, output) {
              isUint8Array("public key", pubkey, [33, 65]);
              isCompressed(compressed);
              output = getAssertedOutput(output, compressed ? 33 : 65);
              switch (secp256k1.publicKeyNegate(output, pubkey)) {
                case 0:
                  return output;
                case 1:
                  throw new Error(errors.PUBKEY_PARSE);
                case 2:
                  throw new Error(errors.IMPOSSIBLE_CASE);
                case 3:
                  throw new Error(errors.PUBKEY_SERIALIZE);
              }
            },
            publicKeyCombine(pubkeys, compressed = true, output) {
              assert(
                Array.isArray(pubkeys),
                "Expected public keys to be an Array"
              );
              assert(
                pubkeys.length > 0,
                "Expected public keys array will have more than zero items"
              );
              for (const pubkey of pubkeys) {
                isUint8Array("public key", pubkey, [33, 65]);
              }
              isCompressed(compressed);
              output = getAssertedOutput(output, compressed ? 33 : 65);
              switch (secp256k1.publicKeyCombine(output, pubkeys)) {
                case 0:
                  return output;
                case 1:
                  throw new Error(errors.PUBKEY_PARSE);
                case 2:
                  throw new Error(errors.PUBKEY_COMBINE);
                case 3:
                  throw new Error(errors.PUBKEY_SERIALIZE);
              }
            },
            publicKeyTweakAdd(pubkey, tweak, compressed = true, output) {
              isUint8Array("public key", pubkey, [33, 65]);
              isUint8Array("tweak", tweak, 32);
              isCompressed(compressed);
              output = getAssertedOutput(output, compressed ? 33 : 65);
              switch (secp256k1.publicKeyTweakAdd(output, pubkey, tweak)) {
                case 0:
                  return output;
                case 1:
                  throw new Error(errors.PUBKEY_PARSE);
                case 2:
                  throw new Error(errors.TWEAK_ADD);
              }
            },
            publicKeyTweakMul(pubkey, tweak, compressed = true, output) {
              isUint8Array("public key", pubkey, [33, 65]);
              isUint8Array("tweak", tweak, 32);
              isCompressed(compressed);
              output = getAssertedOutput(output, compressed ? 33 : 65);
              switch (secp256k1.publicKeyTweakMul(output, pubkey, tweak)) {
                case 0:
                  return output;
                case 1:
                  throw new Error(errors.PUBKEY_PARSE);
                case 2:
                  throw new Error(errors.TWEAK_MUL);
              }
            },
            signatureNormalize(sig) {
              isUint8Array("signature", sig, 64);
              switch (secp256k1.signatureNormalize(sig)) {
                case 0:
                  return sig;
                case 1:
                  throw new Error(errors.SIG_PARSE);
              }
            },
            signatureExport(sig, output) {
              isUint8Array("signature", sig, 64);
              output = getAssertedOutput(output, 72);
              const obj = { output: output, outputlen: 72 };
              switch (secp256k1.signatureExport(obj, sig)) {
                case 0:
                  return output.slice(0, obj.outputlen);
                case 1:
                  throw new Error(errors.SIG_PARSE);
                case 2:
                  throw new Error(errors.IMPOSSIBLE_CASE);
              }
            },
            signatureImport(sig, output) {
              isUint8Array("signature", sig);
              output = getAssertedOutput(output, 64);
              switch (secp256k1.signatureImport(output, sig)) {
                case 0:
                  return output;
                case 1:
                  throw new Error(errors.SIG_PARSE);
                case 2:
                  throw new Error(errors.IMPOSSIBLE_CASE);
              }
            },
            ecdsaSign(msg32, seckey, options = {}, output) {
              isUint8Array("message", msg32, 32);
              isUint8Array("private key", seckey, 32);
              assert(
                toTypeString(options) === "Object",
                "Expected options to be an Object"
              );
              if (options.data !== undefined)
                isUint8Array("options.data", options.data);
              if (options.noncefn !== undefined)
                assert(
                  toTypeString(options.noncefn) === "Function",
                  "Expected options.noncefn to be a Function"
                );
              output = getAssertedOutput(output, 64);
              const obj = { signature: output, recid: null };
              switch (
                secp256k1.ecdsaSign(
                  obj,
                  msg32,
                  seckey,
                  options.data,
                  options.noncefn
                )
              ) {
                case 0:
                  return obj;
                case 1:
                  throw new Error(errors.SIGN);
                case 2:
                  throw new Error(errors.IMPOSSIBLE_CASE);
              }
            },
            ecdsaVerify(sig, msg32, pubkey) {
              isUint8Array("signature", sig, 64);
              isUint8Array("message", msg32, 32);
              isUint8Array("public key", pubkey, [33, 65]);
              switch (secp256k1.ecdsaVerify(sig, msg32, pubkey)) {
                case 0:
                  return true;
                case 3:
                  return false;
                case 1:
                  throw new Error(errors.SIG_PARSE);
                case 2:
                  throw new Error(errors.PUBKEY_PARSE);
              }
            },
            ecdsaRecover(sig, recid, msg32, compressed = true, output) {
              isUint8Array("signature", sig, 64);
              assert(
                toTypeString(recid) === "Number" && recid >= 0 && recid <= 3,
                "Expected recovery id to be a Number within interval [0, 3]"
              );
              isUint8Array("message", msg32, 32);
              isCompressed(compressed);
              output = getAssertedOutput(output, compressed ? 33 : 65);
              switch (secp256k1.ecdsaRecover(output, sig, recid, msg32)) {
                case 0:
                  return output;
                case 1:
                  throw new Error(errors.SIG_PARSE);
                case 2:
                  throw new Error(errors.RECOVER);
                case 3:
                  throw new Error(errors.IMPOSSIBLE_CASE);
              }
            },
            ecdh(pubkey, seckey, options = {}, output) {
              isUint8Array("public key", pubkey, [33, 65]);
              isUint8Array("private key", seckey, 32);
              assert(
                toTypeString(options) === "Object",
                "Expected options to be an Object"
              );
              if (options.data !== undefined)
                isUint8Array("options.data", options.data);
              if (options.hashfn !== undefined) {
                assert(
                  toTypeString(options.hashfn) === "Function",
                  "Expected options.hashfn to be a Function"
                );
                if (options.xbuf !== undefined)
                  isUint8Array("options.xbuf", options.xbuf, 32);
                if (options.ybuf !== undefined)
                  isUint8Array("options.ybuf", options.ybuf, 32);
                isUint8Array("output", output);
              } else {
                output = getAssertedOutput(output, 32);
              }
              switch (
                secp256k1.ecdh(
                  output,
                  pubkey,
                  seckey,
                  options.data,
                  options.hashfn,
                  options.xbuf,
                  options.ybuf
                )
              ) {
                case 0:
                  return output;
                case 1:
                  throw new Error(errors.PUBKEY_PARSE);
                case 2:
                  throw new Error(errors.ECDH);
              }
            },
          };
        };
      },
      {},
    ],
    130: [
      function (require, module, exports) {
        var Buffer = require("safe-buffer").Buffer;
        function Hash(blockSize, finalSize) {
          this._block = Buffer.alloc(blockSize);
          this._finalSize = finalSize;
          this._blockSize = blockSize;
          this._len = 0;
        }
        Hash.prototype.update = function (data, enc) {
          if (typeof data === "string") {
            enc = enc || "utf8";
            data = Buffer.from(data, enc);
          }
          var block = this._block;
          var blockSize = this._blockSize;
          var length = data.length;
          var accum = this._len;
          for (var offset = 0; offset < length; ) {
            var assigned = accum % blockSize;
            var remainder = Math.min(length - offset, blockSize - assigned);
            for (var i = 0; i < remainder; i++) {
              block[assigned + i] = data[offset + i];
            }
            accum += remainder;
            offset += remainder;
            if (accum % blockSize === 0) {
              this._update(block);
            }
          }
          this._len += length;
          return this;
        };
        Hash.prototype.digest = function (enc) {
          var rem = this._len % this._blockSize;
          this._block[rem] = 128;
          this._block.fill(0, rem + 1);
          if (rem >= this._finalSize) {
            this._update(this._block);
            this._block.fill(0);
          }
          var bits = this._len * 8;
          if (bits <= 4294967295) {
            this._block.writeUInt32BE(bits, this._blockSize - 4);
          } else {
            var lowBits = (bits & 4294967295) >>> 0;
            var highBits = (bits - lowBits) / 4294967296;
            this._block.writeUInt32BE(highBits, this._blockSize - 8);
            this._block.writeUInt32BE(lowBits, this._blockSize - 4);
          }
          this._update(this._block);
          var hash = this._hash();
          return enc ? hash.toString(enc) : hash;
        };
        Hash.prototype._update = function () {
          throw new Error("_update must be implemented by subclass");
        };
        module.exports = Hash;
      },
      { "safe-buffer": 126 },
    ],
    131: [
      function (require, module, exports) {
        var exports = (module.exports = function SHA(algorithm) {
          algorithm = algorithm.toLowerCase();
          var Algorithm = exports[algorithm];
          if (!Algorithm)
            throw new Error(
              algorithm + " is not supported (we accept pull requests)"
            );
          return new Algorithm();
        });
        exports.sha = require("./sha");
        exports.sha1 = require("./sha1");
        exports.sha224 = require("./sha224");
        exports.sha256 = require("./sha256");
        exports.sha384 = require("./sha384");
        exports.sha512 = require("./sha512");
      },
      {
        "./sha": 132,
        "./sha1": 133,
        "./sha224": 134,
        "./sha256": 135,
        "./sha384": 136,
        "./sha512": 137,
      },
    ],
    132: [
      function (require, module, exports) {
        var inherits = require("inherits");
        var Hash = require("./hash");
        var Buffer = require("safe-buffer").Buffer;
        var K = [1518500249, 1859775393, 2400959708 | 0, 3395469782 | 0];
        var W = new Array(80);
        function Sha() {
          this.init();
          this._w = W;
          Hash.call(this, 64, 56);
        }
        inherits(Sha, Hash);
        Sha.prototype.init = function () {
          this._a = 1732584193;
          this._b = 4023233417;
          this._c = 2562383102;
          this._d = 271733878;
          this._e = 3285377520;
          return this;
        };
        function rotl5(num) {
          return (num << 5) | (num >>> 27);
        }
        function rotl30(num) {
          return (num << 30) | (num >>> 2);
        }
        function ft(s, b, c, d) {
          if (s === 0) return (b & c) | (~b & d);
          if (s === 2) return (b & c) | (b & d) | (c & d);
          return b ^ c ^ d;
        }
        Sha.prototype._update = function (M) {
          var W = this._w;
          var a = this._a | 0;
          var b = this._b | 0;
          var c = this._c | 0;
          var d = this._d | 0;
          var e = this._e | 0;
          for (var i = 0; i < 16; ++i) W[i] = M.readInt32BE(i * 4);
          for (; i < 80; ++i)
            W[i] = W[i - 3] ^ W[i - 8] ^ W[i - 14] ^ W[i - 16];
          for (var j = 0; j < 80; ++j) {
            var s = ~~(j / 20);
            var t = (rotl5(a) + ft(s, b, c, d) + e + W[j] + K[s]) | 0;
            e = d;
            d = c;
            c = rotl30(b);
            b = a;
            a = t;
          }
          this._a = (a + this._a) | 0;
          this._b = (b + this._b) | 0;
          this._c = (c + this._c) | 0;
          this._d = (d + this._d) | 0;
          this._e = (e + this._e) | 0;
        };
        Sha.prototype._hash = function () {
          var H = Buffer.allocUnsafe(20);
          H.writeInt32BE(this._a | 0, 0);
          H.writeInt32BE(this._b | 0, 4);
          H.writeInt32BE(this._c | 0, 8);
          H.writeInt32BE(this._d | 0, 12);
          H.writeInt32BE(this._e | 0, 16);
          return H;
        };
        module.exports = Sha;
      },
      { "./hash": 130, inherits: 94, "safe-buffer": 126 },
    ],
    133: [
      function (require, module, exports) {
        var inherits = require("inherits");
        var Hash = require("./hash");
        var Buffer = require("safe-buffer").Buffer;
        var K = [1518500249, 1859775393, 2400959708 | 0, 3395469782 | 0];
        var W = new Array(80);
        function Sha1() {
          this.init();
          this._w = W;
          Hash.call(this, 64, 56);
        }
        inherits(Sha1, Hash);
        Sha1.prototype.init = function () {
          this._a = 1732584193;
          this._b = 4023233417;
          this._c = 2562383102;
          this._d = 271733878;
          this._e = 3285377520;
          return this;
        };
        function rotl1(num) {
          return (num << 1) | (num >>> 31);
        }
        function rotl5(num) {
          return (num << 5) | (num >>> 27);
        }
        function rotl30(num) {
          return (num << 30) | (num >>> 2);
        }
        function ft(s, b, c, d) {
          if (s === 0) return (b & c) | (~b & d);
          if (s === 2) return (b & c) | (b & d) | (c & d);
          return b ^ c ^ d;
        }
        Sha1.prototype._update = function (M) {
          var W = this._w;
          var a = this._a | 0;
          var b = this._b | 0;
          var c = this._c | 0;
          var d = this._d | 0;
          var e = this._e | 0;
          for (var i = 0; i < 16; ++i) W[i] = M.readInt32BE(i * 4);
          for (; i < 80; ++i)
            W[i] = rotl1(W[i - 3] ^ W[i - 8] ^ W[i - 14] ^ W[i - 16]);
          for (var j = 0; j < 80; ++j) {
            var s = ~~(j / 20);
            var t = (rotl5(a) + ft(s, b, c, d) + e + W[j] + K[s]) | 0;
            e = d;
            d = c;
            c = rotl30(b);
            b = a;
            a = t;
          }
          this._a = (a + this._a) | 0;
          this._b = (b + this._b) | 0;
          this._c = (c + this._c) | 0;
          this._d = (d + this._d) | 0;
          this._e = (e + this._e) | 0;
        };
        Sha1.prototype._hash = function () {
          var H = Buffer.allocUnsafe(20);
          H.writeInt32BE(this._a | 0, 0);
          H.writeInt32BE(this._b | 0, 4);
          H.writeInt32BE(this._c | 0, 8);
          H.writeInt32BE(this._d | 0, 12);
          H.writeInt32BE(this._e | 0, 16);
          return H;
        };
        module.exports = Sha1;
      },
      { "./hash": 130, inherits: 94, "safe-buffer": 126 },
    ],
    134: [
      function (require, module, exports) {
        var inherits = require("inherits");
        var Sha256 = require("./sha256");
        var Hash = require("./hash");
        var Buffer = require("safe-buffer").Buffer;
        var W = new Array(64);
        function Sha224() {
          this.init();
          this._w = W;
          Hash.call(this, 64, 56);
        }
        inherits(Sha224, Sha256);
        Sha224.prototype.init = function () {
          this._a = 3238371032;
          this._b = 914150663;
          this._c = 812702999;
          this._d = 4144912697;
          this._e = 4290775857;
          this._f = 1750603025;
          this._g = 1694076839;
          this._h = 3204075428;
          return this;
        };
        Sha224.prototype._hash = function () {
          var H = Buffer.allocUnsafe(28);
          H.writeInt32BE(this._a, 0);
          H.writeInt32BE(this._b, 4);
          H.writeInt32BE(this._c, 8);
          H.writeInt32BE(this._d, 12);
          H.writeInt32BE(this._e, 16);
          H.writeInt32BE(this._f, 20);
          H.writeInt32BE(this._g, 24);
          return H;
        };
        module.exports = Sha224;
      },
      { "./hash": 130, "./sha256": 135, inherits: 94, "safe-buffer": 126 },
    ],
    135: [
      function (require, module, exports) {
        var inherits = require("inherits");
        var Hash = require("./hash");
        var Buffer = require("safe-buffer").Buffer;
        var K = [
          1116352408, 1899447441, 3049323471, 3921009573, 961987163, 1508970993,
          2453635748, 2870763221, 3624381080, 310598401, 607225278, 1426881987,
          1925078388, 2162078206, 2614888103, 3248222580, 3835390401,
          4022224774, 264347078, 604807628, 770255983, 1249150122, 1555081692,
          1996064986, 2554220882, 2821834349, 2952996808, 3210313671,
          3336571891, 3584528711, 113926993, 338241895, 666307205, 773529912,
          1294757372, 1396182291, 1695183700, 1986661051, 2177026350,
          2456956037, 2730485921, 2820302411, 3259730800, 3345764771,
          3516065817, 3600352804, 4094571909, 275423344, 430227734, 506948616,
          659060556, 883997877, 958139571, 1322822218, 1537002063, 1747873779,
          1955562222, 2024104815, 2227730452, 2361852424, 2428436474,
          2756734187, 3204031479, 3329325298,
        ];
        var W = new Array(64);
        function Sha256() {
          this.init();
          this._w = W;
          Hash.call(this, 64, 56);
        }
        inherits(Sha256, Hash);
        Sha256.prototype.init = function () {
          this._a = 1779033703;
          this._b = 3144134277;
          this._c = 1013904242;
          this._d = 2773480762;
          this._e = 1359893119;
          this._f = 2600822924;
          this._g = 528734635;
          this._h = 1541459225;
          return this;
        };
        function ch(x, y, z) {
          return z ^ (x & (y ^ z));
        }
        function maj(x, y, z) {
          return (x & y) | (z & (x | y));
        }
        function sigma0(x) {
          return (
            ((x >>> 2) | (x << 30)) ^
            ((x >>> 13) | (x << 19)) ^
            ((x >>> 22) | (x << 10))
          );
        }
        function sigma1(x) {
          return (
            ((x >>> 6) | (x << 26)) ^
            ((x >>> 11) | (x << 21)) ^
            ((x >>> 25) | (x << 7))
          );
        }
        function gamma0(x) {
          return ((x >>> 7) | (x << 25)) ^ ((x >>> 18) | (x << 14)) ^ (x >>> 3);
        }
        function gamma1(x) {
          return (
            ((x >>> 17) | (x << 15)) ^ ((x >>> 19) | (x << 13)) ^ (x >>> 10)
          );
        }
        Sha256.prototype._update = function (M) {
          var W = this._w;
          var a = this._a | 0;
          var b = this._b | 0;
          var c = this._c | 0;
          var d = this._d | 0;
          var e = this._e | 0;
          var f = this._f | 0;
          var g = this._g | 0;
          var h = this._h | 0;
          for (var i = 0; i < 16; ++i) W[i] = M.readInt32BE(i * 4);
          for (; i < 64; ++i)
            W[i] =
              (gamma1(W[i - 2]) + W[i - 7] + gamma0(W[i - 15]) + W[i - 16]) | 0;
          for (var j = 0; j < 64; ++j) {
            var T1 = (h + sigma1(e) + ch(e, f, g) + K[j] + W[j]) | 0;
            var T2 = (sigma0(a) + maj(a, b, c)) | 0;
            h = g;
            g = f;
            f = e;
            e = (d + T1) | 0;
            d = c;
            c = b;
            b = a;
            a = (T1 + T2) | 0;
          }
          this._a = (a + this._a) | 0;
          this._b = (b + this._b) | 0;
          this._c = (c + this._c) | 0;
          this._d = (d + this._d) | 0;
          this._e = (e + this._e) | 0;
          this._f = (f + this._f) | 0;
          this._g = (g + this._g) | 0;
          this._h = (h + this._h) | 0;
        };
        Sha256.prototype._hash = function () {
          var H = Buffer.allocUnsafe(32);
          H.writeInt32BE(this._a, 0);
          H.writeInt32BE(this._b, 4);
          H.writeInt32BE(this._c, 8);
          H.writeInt32BE(this._d, 12);
          H.writeInt32BE(this._e, 16);
          H.writeInt32BE(this._f, 20);
          H.writeInt32BE(this._g, 24);
          H.writeInt32BE(this._h, 28);
          return H;
        };
        module.exports = Sha256;
      },
      { "./hash": 130, inherits: 94, "safe-buffer": 126 },
    ],
    136: [
      function (require, module, exports) {
        var inherits = require("inherits");
        var SHA512 = require("./sha512");
        var Hash = require("./hash");
        var Buffer = require("safe-buffer").Buffer;
        var W = new Array(160);
        function Sha384() {
          this.init();
          this._w = W;
          Hash.call(this, 128, 112);
        }
        inherits(Sha384, SHA512);
        Sha384.prototype.init = function () {
          this._ah = 3418070365;
          this._bh = 1654270250;
          this._ch = 2438529370;
          this._dh = 355462360;
          this._eh = 1731405415;
          this._fh = 2394180231;
          this._gh = 3675008525;
          this._hh = 1203062813;
          this._al = 3238371032;
          this._bl = 914150663;
          this._cl = 812702999;
          this._dl = 4144912697;
          this._el = 4290775857;
          this._fl = 1750603025;
          this._gl = 1694076839;
          this._hl = 3204075428;
          return this;
        };
        Sha384.prototype._hash = function () {
          var H = Buffer.allocUnsafe(48);
          function writeInt64BE(h, l, offset) {
            H.writeInt32BE(h, offset);
            H.writeInt32BE(l, offset + 4);
          }
          writeInt64BE(this._ah, this._al, 0);
          writeInt64BE(this._bh, this._bl, 8);
          writeInt64BE(this._ch, this._cl, 16);
          writeInt64BE(this._dh, this._dl, 24);
          writeInt64BE(this._eh, this._el, 32);
          writeInt64BE(this._fh, this._fl, 40);
          return H;
        };
        module.exports = Sha384;
      },
      { "./hash": 130, "./sha512": 137, inherits: 94, "safe-buffer": 126 },
    ],
    137: [
      function (require, module, exports) {
        var inherits = require("inherits");
        var Hash = require("./hash");
        var Buffer = require("safe-buffer").Buffer;
        var K = [
          1116352408, 3609767458, 1899447441, 602891725, 3049323471, 3964484399,
          3921009573, 2173295548, 961987163, 4081628472, 1508970993, 3053834265,
          2453635748, 2937671579, 2870763221, 3664609560, 3624381080,
          2734883394, 310598401, 1164996542, 607225278, 1323610764, 1426881987,
          3590304994, 1925078388, 4068182383, 2162078206, 991336113, 2614888103,
          633803317, 3248222580, 3479774868, 3835390401, 2666613458, 4022224774,
          944711139, 264347078, 2341262773, 604807628, 2007800933, 770255983,
          1495990901, 1249150122, 1856431235, 1555081692, 3175218132,
          1996064986, 2198950837, 2554220882, 3999719339, 2821834349, 766784016,
          2952996808, 2566594879, 3210313671, 3203337956, 3336571891,
          1034457026, 3584528711, 2466948901, 113926993, 3758326383, 338241895,
          168717936, 666307205, 1188179964, 773529912, 1546045734, 1294757372,
          1522805485, 1396182291, 2643833823, 1695183700, 2343527390,
          1986661051, 1014477480, 2177026350, 1206759142, 2456956037, 344077627,
          2730485921, 1290863460, 2820302411, 3158454273, 3259730800,
          3505952657, 3345764771, 106217008, 3516065817, 3606008344, 3600352804,
          1432725776, 4094571909, 1467031594, 275423344, 851169720, 430227734,
          3100823752, 506948616, 1363258195, 659060556, 3750685593, 883997877,
          3785050280, 958139571, 3318307427, 1322822218, 3812723403, 1537002063,
          2003034995, 1747873779, 3602036899, 1955562222, 1575990012,
          2024104815, 1125592928, 2227730452, 2716904306, 2361852424, 442776044,
          2428436474, 593698344, 2756734187, 3733110249, 3204031479, 2999351573,
          3329325298, 3815920427, 3391569614, 3928383900, 3515267271, 566280711,
          3940187606, 3454069534, 4118630271, 4000239992, 116418474, 1914138554,
          174292421, 2731055270, 289380356, 3203993006, 460393269, 320620315,
          685471733, 587496836, 852142971, 1086792851, 1017036298, 365543100,
          1126000580, 2618297676, 1288033470, 3409855158, 1501505948,
          4234509866, 1607167915, 987167468, 1816402316, 1246189591,
        ];
        var W = new Array(160);
        function Sha512() {
          this.init();
          this._w = W;
          Hash.call(this, 128, 112);
        }
        inherits(Sha512, Hash);
        Sha512.prototype.init = function () {
          this._ah = 1779033703;
          this._bh = 3144134277;
          this._ch = 1013904242;
          this._dh = 2773480762;
          this._eh = 1359893119;
          this._fh = 2600822924;
          this._gh = 528734635;
          this._hh = 1541459225;
          this._al = 4089235720;
          this._bl = 2227873595;
          this._cl = 4271175723;
          this._dl = 1595750129;
          this._el = 2917565137;
          this._fl = 725511199;
          this._gl = 4215389547;
          this._hl = 327033209;
          return this;
        };
        function Ch(x, y, z) {
          return z ^ (x & (y ^ z));
        }
        function maj(x, y, z) {
          return (x & y) | (z & (x | y));
        }
        function sigma0(x, xl) {
          return (
            ((x >>> 28) | (xl << 4)) ^
            ((xl >>> 2) | (x << 30)) ^
            ((xl >>> 7) | (x << 25))
          );
        }
        function sigma1(x, xl) {
          return (
            ((x >>> 14) | (xl << 18)) ^
            ((x >>> 18) | (xl << 14)) ^
            ((xl >>> 9) | (x << 23))
          );
        }
        function Gamma0(x, xl) {
          return (
            ((x >>> 1) | (xl << 31)) ^ ((x >>> 8) | (xl << 24)) ^ (x >>> 7)
          );
        }
        function Gamma0l(x, xl) {
          return (
            ((x >>> 1) | (xl << 31)) ^
            ((x >>> 8) | (xl << 24)) ^
            ((x >>> 7) | (xl << 25))
          );
        }
        function Gamma1(x, xl) {
          return (
            ((x >>> 19) | (xl << 13)) ^ ((xl >>> 29) | (x << 3)) ^ (x >>> 6)
          );
        }
        function Gamma1l(x, xl) {
          return (
            ((x >>> 19) | (xl << 13)) ^
            ((xl >>> 29) | (x << 3)) ^
            ((x >>> 6) | (xl << 26))
          );
        }
        function getCarry(a, b) {
          return a >>> 0 < b >>> 0 ? 1 : 0;
        }
        Sha512.prototype._update = function (M) {
          var W = this._w;
          var ah = this._ah | 0;
          var bh = this._bh | 0;
          var ch = this._ch | 0;
          var dh = this._dh | 0;
          var eh = this._eh | 0;
          var fh = this._fh | 0;
          var gh = this._gh | 0;
          var hh = this._hh | 0;
          var al = this._al | 0;
          var bl = this._bl | 0;
          var cl = this._cl | 0;
          var dl = this._dl | 0;
          var el = this._el | 0;
          var fl = this._fl | 0;
          var gl = this._gl | 0;
          var hl = this._hl | 0;
          for (var i = 0; i < 32; i += 2) {
            W[i] = M.readInt32BE(i * 4);
            W[i + 1] = M.readInt32BE(i * 4 + 4);
          }
          for (; i < 160; i += 2) {
            var xh = W[i - 15 * 2];
            var xl = W[i - 15 * 2 + 1];
            var gamma0 = Gamma0(xh, xl);
            var gamma0l = Gamma0l(xl, xh);
            xh = W[i - 2 * 2];
            xl = W[i - 2 * 2 + 1];
            var gamma1 = Gamma1(xh, xl);
            var gamma1l = Gamma1l(xl, xh);
            var Wi7h = W[i - 7 * 2];
            var Wi7l = W[i - 7 * 2 + 1];
            var Wi16h = W[i - 16 * 2];
            var Wi16l = W[i - 16 * 2 + 1];
            var Wil = (gamma0l + Wi7l) | 0;
            var Wih = (gamma0 + Wi7h + getCarry(Wil, gamma0l)) | 0;
            Wil = (Wil + gamma1l) | 0;
            Wih = (Wih + gamma1 + getCarry(Wil, gamma1l)) | 0;
            Wil = (Wil + Wi16l) | 0;
            Wih = (Wih + Wi16h + getCarry(Wil, Wi16l)) | 0;
            W[i] = Wih;
            W[i + 1] = Wil;
          }
          for (var j = 0; j < 160; j += 2) {
            Wih = W[j];
            Wil = W[j + 1];
            var majh = maj(ah, bh, ch);
            var majl = maj(al, bl, cl);
            var sigma0h = sigma0(ah, al);
            var sigma0l = sigma0(al, ah);
            var sigma1h = sigma1(eh, el);
            var sigma1l = sigma1(el, eh);
            var Kih = K[j];
            var Kil = K[j + 1];
            var chh = Ch(eh, fh, gh);
            var chl = Ch(el, fl, gl);
            var t1l = (hl + sigma1l) | 0;
            var t1h = (hh + sigma1h + getCarry(t1l, hl)) | 0;
            t1l = (t1l + chl) | 0;
            t1h = (t1h + chh + getCarry(t1l, chl)) | 0;
            t1l = (t1l + Kil) | 0;
            t1h = (t1h + Kih + getCarry(t1l, Kil)) | 0;
            t1l = (t1l + Wil) | 0;
            t1h = (t1h + Wih + getCarry(t1l, Wil)) | 0;
            var t2l = (sigma0l + majl) | 0;
            var t2h = (sigma0h + majh + getCarry(t2l, sigma0l)) | 0;
            hh = gh;
            hl = gl;
            gh = fh;
            gl = fl;
            fh = eh;
            fl = el;
            el = (dl + t1l) | 0;
            eh = (dh + t1h + getCarry(el, dl)) | 0;
            dh = ch;
            dl = cl;
            ch = bh;
            cl = bl;
            bh = ah;
            bl = al;
            al = (t1l + t2l) | 0;
            ah = (t1h + t2h + getCarry(al, t1l)) | 0;
          }
          this._al = (this._al + al) | 0;
          this._bl = (this._bl + bl) | 0;
          this._cl = (this._cl + cl) | 0;
          this._dl = (this._dl + dl) | 0;
          this._el = (this._el + el) | 0;
          this._fl = (this._fl + fl) | 0;
          this._gl = (this._gl + gl) | 0;
          this._hl = (this._hl + hl) | 0;
          this._ah = (this._ah + ah + getCarry(this._al, al)) | 0;
          this._bh = (this._bh + bh + getCarry(this._bl, bl)) | 0;
          this._ch = (this._ch + ch + getCarry(this._cl, cl)) | 0;
          this._dh = (this._dh + dh + getCarry(this._dl, dl)) | 0;
          this._eh = (this._eh + eh + getCarry(this._el, el)) | 0;
          this._fh = (this._fh + fh + getCarry(this._fl, fl)) | 0;
          this._gh = (this._gh + gh + getCarry(this._gl, gl)) | 0;
          this._hh = (this._hh + hh + getCarry(this._hl, hl)) | 0;
        };
        Sha512.prototype._hash = function () {
          var H = Buffer.allocUnsafe(64);
          function writeInt64BE(h, l, offset) {
            H.writeInt32BE(h, offset);
            H.writeInt32BE(l, offset + 4);
          }
          writeInt64BE(this._ah, this._al, 0);
          writeInt64BE(this._bh, this._bl, 8);
          writeInt64BE(this._ch, this._cl, 16);
          writeInt64BE(this._dh, this._dl, 24);
          writeInt64BE(this._eh, this._el, 32);
          writeInt64BE(this._fh, this._fl, 40);
          writeInt64BE(this._gh, this._gl, 48);
          writeInt64BE(this._hh, this._hl, 56);
          return H;
        };
        module.exports = Sha512;
      },
      { "./hash": 130, inherits: 94, "safe-buffer": 126 },
    ],
    138: [
      function (require, module, exports) {
        module.exports = Stream;
        var EE = require("events").EventEmitter;
        var inherits = require("inherits");
        inherits(Stream, EE);
        Stream.Readable = require("readable-stream/lib/_stream_readable.js");
        Stream.Writable = require("readable-stream/lib/_stream_writable.js");
        Stream.Duplex = require("readable-stream/lib/_stream_duplex.js");
        Stream.Transform = require("readable-stream/lib/_stream_transform.js");
        Stream.PassThrough = require("readable-stream/lib/_stream_passthrough.js");
        Stream.finished = require("readable-stream/lib/internal/streams/end-of-stream.js");
        Stream.pipeline = require("readable-stream/lib/internal/streams/pipeline.js");
        Stream.Stream = Stream;
        function Stream() {
          EE.call(this);
        }
        Stream.prototype.pipe = function (dest, options) {
          var source = this;
          function ondata(chunk) {
            if (dest.writable) {
              if (false === dest.write(chunk) && source.pause) {
                source.pause();
              }
            }
          }
          source.on("data", ondata);
          function ondrain() {
            if (source.readable && source.resume) {
              source.resume();
            }
          }
          dest.on("drain", ondrain);
          if (!dest._isStdio && (!options || options.end !== false)) {
            source.on("end", onend);
            source.on("close", onclose);
          }
          var didOnEnd = false;
          function onend() {
            if (didOnEnd) return;
            didOnEnd = true;
            dest.end();
          }
          function onclose() {
            if (didOnEnd) return;
            didOnEnd = true;
            if (typeof dest.destroy === "function") dest.destroy();
          }
          function onerror(er) {
            cleanup();
            if (EE.listenerCount(this, "error") === 0) {
              throw er;
            }
          }
          source.on("error", onerror);
          dest.on("error", onerror);
          function cleanup() {
            source.removeListener("data", ondata);
            dest.removeListener("drain", ondrain);
            source.removeListener("end", onend);
            source.removeListener("close", onclose);
            source.removeListener("error", onerror);
            dest.removeListener("error", onerror);
            source.removeListener("end", cleanup);
            source.removeListener("close", cleanup);
            dest.removeListener("close", cleanup);
          }
          source.on("end", cleanup);
          source.on("close", cleanup);
          dest.on("close", cleanup);
          dest.emit("pipe", source);
          return dest;
        };
      },
      {
        events: 63,
        inherits: 94,
        "readable-stream/lib/_stream_duplex.js": 140,
        "readable-stream/lib/_stream_passthrough.js": 141,
        "readable-stream/lib/_stream_readable.js": 142,
        "readable-stream/lib/_stream_transform.js": 143,
        "readable-stream/lib/_stream_writable.js": 144,
        "readable-stream/lib/internal/streams/end-of-stream.js": 148,
        "readable-stream/lib/internal/streams/pipeline.js": 150,
      },
    ],
    139: [
      function (require, module, exports) {
        arguments[4][65][0].apply(exports, arguments);
      },
      { dup: 65 },
    ],
    140: [
      function (require, module, exports) {
        arguments[4][66][0].apply(exports, arguments);
      },
      {
        "./_stream_readable": 142,
        "./_stream_writable": 144,
        _process: 122,
        dup: 66,
        inherits: 94,
      },
    ],
    141: [
      function (require, module, exports) {
        arguments[4][67][0].apply(exports, arguments);
      },
      { "./_stream_transform": 143, dup: 67, inherits: 94 },
    ],
    142: [
      function (require, module, exports) {
        arguments[4][68][0].apply(exports, arguments);
      },
      {
        "../errors": 139,
        "./_stream_duplex": 140,
        "./internal/streams/async_iterator": 145,
        "./internal/streams/buffer_list": 146,
        "./internal/streams/destroy": 147,
        "./internal/streams/from": 149,
        "./internal/streams/state": 151,
        "./internal/streams/stream": 152,
        _process: 122,
        buffer: 25,
        dup: 68,
        events: 63,
        inherits: 94,
        "string_decoder/": 153,
        util: 24,
      },
    ],
    143: [
      function (require, module, exports) {
        arguments[4][69][0].apply(exports, arguments);
      },
      { "../errors": 139, "./_stream_duplex": 140, dup: 69, inherits: 94 },
    ],
    144: [
      function (require, module, exports) {
        arguments[4][70][0].apply(exports, arguments);
      },
      {
        "../errors": 139,
        "./_stream_duplex": 140,
        "./internal/streams/destroy": 147,
        "./internal/streams/state": 151,
        "./internal/streams/stream": 152,
        _process: 122,
        buffer: 25,
        dup: 70,
        inherits: 94,
        "util-deprecate": 157,
      },
    ],
    145: [
      function (require, module, exports) {
        arguments[4][71][0].apply(exports, arguments);
      },
      { "./end-of-stream": 148, _process: 122, dup: 71 },
    ],
    146: [
      function (require, module, exports) {
        arguments[4][72][0].apply(exports, arguments);
      },
      { buffer: 25, dup: 72, util: 24 },
    ],
    147: [
      function (require, module, exports) {
        arguments[4][73][0].apply(exports, arguments);
      },
      { _process: 122, dup: 73 },
    ],
    148: [
      function (require, module, exports) {
        arguments[4][74][0].apply(exports, arguments);
      },
      { "../../../errors": 139, dup: 74 },
    ],
    149: [
      function (require, module, exports) {
        arguments[4][75][0].apply(exports, arguments);
      },
      { dup: 75 },
    ],
    150: [
      function (require, module, exports) {
        arguments[4][76][0].apply(exports, arguments);
      },
      { "../../../errors": 139, "./end-of-stream": 148, dup: 76 },
    ],
    151: [
      function (require, module, exports) {
        arguments[4][77][0].apply(exports, arguments);
      },
      { "../../../errors": 139, dup: 77 },
    ],
    152: [
      function (require, module, exports) {
        arguments[4][78][0].apply(exports, arguments);
      },
      { dup: 78, events: 63 },
    ],
    153: [
      function (require, module, exports) {
        "use strict";
        var Buffer = require("safe-buffer").Buffer;
        var isEncoding =
          Buffer.isEncoding ||
          function (encoding) {
            encoding = "" + encoding;
            switch (encoding && encoding.toLowerCase()) {
              case "hex":
              case "utf8":
              case "utf-8":
              case "ascii":
              case "binary":
              case "base64":
              case "ucs2":
              case "ucs-2":
              case "utf16le":
              case "utf-16le":
              case "raw":
                return true;
              default:
                return false;
            }
          };
        function _normalizeEncoding(enc) {
          if (!enc) return "utf8";
          var retried;
          while (true) {
            switch (enc) {
              case "utf8":
              case "utf-8":
                return "utf8";
              case "ucs2":
              case "ucs-2":
              case "utf16le":
              case "utf-16le":
                return "utf16le";
              case "latin1":
              case "binary":
                return "latin1";
              case "base64":
              case "ascii":
              case "hex":
                return enc;
              default:
                if (retried) return;
                enc = ("" + enc).toLowerCase();
                retried = true;
            }
          }
        }
        function normalizeEncoding(enc) {
          var nenc = _normalizeEncoding(enc);
          if (
            typeof nenc !== "string" &&
            (Buffer.isEncoding === isEncoding || !isEncoding(enc))
          )
            throw new Error("Unknown encoding: " + enc);
          return nenc || enc;
        }
        exports.StringDecoder = StringDecoder;
        function StringDecoder(encoding) {
          this.encoding = normalizeEncoding(encoding);
          var nb;
          switch (this.encoding) {
            case "utf16le":
              this.text = utf16Text;
              this.end = utf16End;
              nb = 4;
              break;
            case "utf8":
              this.fillLast = utf8FillLast;
              nb = 4;
              break;
            case "base64":
              this.text = base64Text;
              this.end = base64End;
              nb = 3;
              break;
            default:
              this.write = simpleWrite;
              this.end = simpleEnd;
              return;
          }
          this.lastNeed = 0;
          this.lastTotal = 0;
          this.lastChar = Buffer.allocUnsafe(nb);
        }
        StringDecoder.prototype.write = function (buf) {
          if (buf.length === 0) return "";
          var r;
          var i;
          if (this.lastNeed) {
            r = this.fillLast(buf);
            if (r === undefined) return "";
            i = this.lastNeed;
            this.lastNeed = 0;
          } else {
            i = 0;
          }
          if (i < buf.length)
            return r ? r + this.text(buf, i) : this.text(buf, i);
          return r || "";
        };
        StringDecoder.prototype.end = utf8End;
        StringDecoder.prototype.text = utf8Text;
        StringDecoder.prototype.fillLast = function (buf) {
          if (this.lastNeed <= buf.length) {
            buf.copy(
              this.lastChar,
              this.lastTotal - this.lastNeed,
              0,
              this.lastNeed
            );
            return this.lastChar.toString(this.encoding, 0, this.lastTotal);
          }
          buf.copy(
            this.lastChar,
            this.lastTotal - this.lastNeed,
            0,
            buf.length
          );
          this.lastNeed -= buf.length;
        };
        function utf8CheckByte(byte) {
          if (byte <= 127) return 0;
          else if (byte >> 5 === 6) return 2;
          else if (byte >> 4 === 14) return 3;
          else if (byte >> 3 === 30) return 4;
          return byte >> 6 === 2 ? -1 : -2;
        }
        function utf8CheckIncomplete(self, buf, i) {
          var j = buf.length - 1;
          if (j < i) return 0;
          var nb = utf8CheckByte(buf[j]);
          if (nb >= 0) {
            if (nb > 0) self.lastNeed = nb - 1;
            return nb;
          }
          if (--j < i || nb === -2) return 0;
          nb = utf8CheckByte(buf[j]);
          if (nb >= 0) {
            if (nb > 0) self.lastNeed = nb - 2;
            return nb;
          }
          if (--j < i || nb === -2) return 0;
          nb = utf8CheckByte(buf[j]);
          if (nb >= 0) {
            if (nb > 0) {
              if (nb === 2) nb = 0;
              else self.lastNeed = nb - 3;
            }
            return nb;
          }
          return 0;
        }
        function utf8CheckExtraBytes(self, buf, p) {
          if ((buf[0] & 192) !== 128) {
            self.lastNeed = 0;
            return "�";
          }
          if (self.lastNeed > 1 && buf.length > 1) {
            if ((buf[1] & 192) !== 128) {
              self.lastNeed = 1;
              return "�";
            }
            if (self.lastNeed > 2 && buf.length > 2) {
              if ((buf[2] & 192) !== 128) {
                self.lastNeed = 2;
                return "�";
              }
            }
          }
        }
        function utf8FillLast(buf) {
          var p = this.lastTotal - this.lastNeed;
          var r = utf8CheckExtraBytes(this, buf, p);
          if (r !== undefined) return r;
          if (this.lastNeed <= buf.length) {
            buf.copy(this.lastChar, p, 0, this.lastNeed);
            return this.lastChar.toString(this.encoding, 0, this.lastTotal);
          }
          buf.copy(this.lastChar, p, 0, buf.length);
          this.lastNeed -= buf.length;
        }
        function utf8Text(buf, i) {
          var total = utf8CheckIncomplete(this, buf, i);
          if (!this.lastNeed) return buf.toString("utf8", i);
          this.lastTotal = total;
          var end = buf.length - (total - this.lastNeed);
          buf.copy(this.lastChar, 0, end);
          return buf.toString("utf8", i, end);
        }
        function utf8End(buf) {
          var r = buf && buf.length ? this.write(buf) : "";
          if (this.lastNeed) return r + "�";
          return r;
        }
        function utf16Text(buf, i) {
          if ((buf.length - i) % 2 === 0) {
            var r = buf.toString("utf16le", i);
            if (r) {
              var c = r.charCodeAt(r.length - 1);
              if (c >= 55296 && c <= 56319) {
                this.lastNeed = 2;
                this.lastTotal = 4;
                this.lastChar[0] = buf[buf.length - 2];
                this.lastChar[1] = buf[buf.length - 1];
                return r.slice(0, -1);
              }
            }
            return r;
          }
          this.lastNeed = 1;
          this.lastTotal = 2;
          this.lastChar[0] = buf[buf.length - 1];
          return buf.toString("utf16le", i, buf.length - 1);
        }
        function utf16End(buf) {
          var r = buf && buf.length ? this.write(buf) : "";
          if (this.lastNeed) {
            var end = this.lastTotal - this.lastNeed;
            return r + this.lastChar.toString("utf16le", 0, end);
          }
          return r;
        }
        function base64Text(buf, i) {
          var n = (buf.length - i) % 3;
          if (n === 0) return buf.toString("base64", i);
          this.lastNeed = 3 - n;
          this.lastTotal = 3;
          if (n === 1) {
            this.lastChar[0] = buf[buf.length - 1];
          } else {
            this.lastChar[0] = buf[buf.length - 2];
            this.lastChar[1] = buf[buf.length - 1];
          }
          return buf.toString("base64", i, buf.length - n);
        }
        function base64End(buf) {
          var r = buf && buf.length ? this.write(buf) : "";
          if (this.lastNeed)
            return r + this.lastChar.toString("base64", 0, 3 - this.lastNeed);
          return r;
        }
        function simpleWrite(buf) {
          return buf.toString(this.encoding);
        }
        function simpleEnd(buf) {
          return buf && buf.length ? this.write(buf) : "";
        }
      },
      { "safe-buffer": 126 },
    ],
    154: [
      function (require, module, exports) {
        var isHexPrefixed = require("is-hex-prefixed");
        module.exports = function stripHexPrefix(str) {
          if (typeof str !== "string") {
            return str;
          }
          return isHexPrefixed(str) ? str.slice(2) : str;
        };
      },
      { "is-hex-prefixed": 95 },
    ],
    155: [
      function (require, module, exports) {
        (function (Buffer) {
          (function () {
            (function (root, f) {
              "use strict";
              if (typeof module !== "undefined" && module.exports)
                module.exports = f();
              else if (root.nacl) root.nacl.util = f();
              else {
                root.nacl = {};
                root.nacl.util = f();
              }
            })(this, function () {
              "use strict";
              var util = {};
              function validateBase64(s) {
                if (
                  !/^(?:[A-Za-z0-9+\/]{2}[A-Za-z0-9+\/]{2})*(?:[A-Za-z0-9+\/]{2}==|[A-Za-z0-9+\/]{3}=)?$/.test(
                    s
                  )
                ) {
                  throw new TypeError("invalid encoding");
                }
              }
              util.decodeUTF8 = function (s) {
                if (typeof s !== "string")
                  throw new TypeError("expected string");
                var i,
                  d = unescape(encodeURIComponent(s)),
                  b = new Uint8Array(d.length);
                for (i = 0; i < d.length; i++) b[i] = d.charCodeAt(i);
                return b;
              };
              util.encodeUTF8 = function (arr) {
                var i,
                  s = [];
                for (i = 0; i < arr.length; i++)
                  s.push(String.fromCharCode(arr[i]));
                return decodeURIComponent(escape(s.join("")));
              };
              if (typeof atob === "undefined") {
                if (typeof Buffer.from !== "undefined") {
                  util.encodeBase64 = function (arr) {
                    return Buffer.from(arr).toString("base64");
                  };
                  util.decodeBase64 = function (s) {
                    validateBase64(s);
                    return new Uint8Array(
                      Array.prototype.slice.call(Buffer.from(s, "base64"), 0)
                    );
                  };
                } else {
                  util.encodeBase64 = function (arr) {
                    return new Buffer(arr).toString("base64");
                  };
                  util.decodeBase64 = function (s) {
                    validateBase64(s);
                    return new Uint8Array(
                      Array.prototype.slice.call(new Buffer(s, "base64"), 0)
                    );
                  };
                }
              } else {
                util.encodeBase64 = function (arr) {
                  var i,
                    s = [],
                    len = arr.length;
                  for (i = 0; i < len; i++) s.push(String.fromCharCode(arr[i]));
                  return btoa(s.join(""));
                };
                util.decodeBase64 = function (s) {
                  validateBase64(s);
                  var i,
                    d = atob(s),
                    b = new Uint8Array(d.length);
                  for (i = 0; i < d.length; i++) b[i] = d.charCodeAt(i);
                  return b;
                };
              }
              return util;
            });
          }).call(this);
        }).call(this, require("buffer").Buffer);
      },
      { buffer: 24 },
    ],
    156: [
      function (require, module, exports) {
        (function (nacl) {
          "use strict";
          var gf = function (init) {
            var i,
              r = new Float64Array(16);
            if (init) for (i = 0; i < init.length; i++) r[i] = init[i];
            return r;
          };
          var randombytes = function () {
            throw new Error("no PRNG");
          };
          var _0 = new Uint8Array(16);
          var _9 = new Uint8Array(32);
          _9[0] = 9;
          var gf0 = gf(),
            gf1 = gf([1]),
            _121665 = gf([56129, 1]),
            D = gf([
              30883, 4953, 19914, 30187, 55467, 16705, 2637, 112, 59544, 30585,
              16505, 36039, 65139, 11119, 27886, 20995,
            ]),
            D2 = gf([
              61785, 9906, 39828, 60374, 45398, 33411, 5274, 224, 53552, 61171,
              33010, 6542, 64743, 22239, 55772, 9222,
            ]),
            X = gf([
              54554, 36645, 11616, 51542, 42930, 38181, 51040, 26924, 56412,
              64982, 57905, 49316, 21502, 52590, 14035, 8553,
            ]),
            Y = gf([
              26200, 26214, 26214, 26214, 26214, 26214, 26214, 26214, 26214,
              26214, 26214, 26214, 26214, 26214, 26214, 26214,
            ]),
            I = gf([
              41136, 18958, 6951, 50414, 58488, 44335, 6150, 12099, 55207,
              15867, 153, 11085, 57099, 20417, 9344, 11139,
            ]);
          function ts64(x, i, h, l) {
            x[i] = (h >> 24) & 255;
            x[i + 1] = (h >> 16) & 255;
            x[i + 2] = (h >> 8) & 255;
            x[i + 3] = h & 255;
            x[i + 4] = (l >> 24) & 255;
            x[i + 5] = (l >> 16) & 255;
            x[i + 6] = (l >> 8) & 255;
            x[i + 7] = l & 255;
          }
          function vn(x, xi, y, yi, n) {
            var i,
              d = 0;
            for (i = 0; i < n; i++) d |= x[xi + i] ^ y[yi + i];
            return (1 & ((d - 1) >>> 8)) - 1;
          }
          function crypto_verify_16(x, xi, y, yi) {
            return vn(x, xi, y, yi, 16);
          }
          function crypto_verify_32(x, xi, y, yi) {
            return vn(x, xi, y, yi, 32);
          }
          function core_salsa20(o, p, k, c) {
            var j0 =
                (c[0] & 255) |
                ((c[1] & 255) << 8) |
                ((c[2] & 255) << 16) |
                ((c[3] & 255) << 24),
              j1 =
                (k[0] & 255) |
                ((k[1] & 255) << 8) |
                ((k[2] & 255) << 16) |
                ((k[3] & 255) << 24),
              j2 =
                (k[4] & 255) |
                ((k[5] & 255) << 8) |
                ((k[6] & 255) << 16) |
                ((k[7] & 255) << 24),
              j3 =
                (k[8] & 255) |
                ((k[9] & 255) << 8) |
                ((k[10] & 255) << 16) |
                ((k[11] & 255) << 24),
              j4 =
                (k[12] & 255) |
                ((k[13] & 255) << 8) |
                ((k[14] & 255) << 16) |
                ((k[15] & 255) << 24),
              j5 =
                (c[4] & 255) |
                ((c[5] & 255) << 8) |
                ((c[6] & 255) << 16) |
                ((c[7] & 255) << 24),
              j6 =
                (p[0] & 255) |
                ((p[1] & 255) << 8) |
                ((p[2] & 255) << 16) |
                ((p[3] & 255) << 24),
              j7 =
                (p[4] & 255) |
                ((p[5] & 255) << 8) |
                ((p[6] & 255) << 16) |
                ((p[7] & 255) << 24),
              j8 =
                (p[8] & 255) |
                ((p[9] & 255) << 8) |
                ((p[10] & 255) << 16) |
                ((p[11] & 255) << 24),
              j9 =
                (p[12] & 255) |
                ((p[13] & 255) << 8) |
                ((p[14] & 255) << 16) |
                ((p[15] & 255) << 24),
              j10 =
                (c[8] & 255) |
                ((c[9] & 255) << 8) |
                ((c[10] & 255) << 16) |
                ((c[11] & 255) << 24),
              j11 =
                (k[16] & 255) |
                ((k[17] & 255) << 8) |
                ((k[18] & 255) << 16) |
                ((k[19] & 255) << 24),
              j12 =
                (k[20] & 255) |
                ((k[21] & 255) << 8) |
                ((k[22] & 255) << 16) |
                ((k[23] & 255) << 24),
              j13 =
                (k[24] & 255) |
                ((k[25] & 255) << 8) |
                ((k[26] & 255) << 16) |
                ((k[27] & 255) << 24),
              j14 =
                (k[28] & 255) |
                ((k[29] & 255) << 8) |
                ((k[30] & 255) << 16) |
                ((k[31] & 255) << 24),
              j15 =
                (c[12] & 255) |
                ((c[13] & 255) << 8) |
                ((c[14] & 255) << 16) |
                ((c[15] & 255) << 24);
            var x0 = j0,
              x1 = j1,
              x2 = j2,
              x3 = j3,
              x4 = j4,
              x5 = j5,
              x6 = j6,
              x7 = j7,
              x8 = j8,
              x9 = j9,
              x10 = j10,
              x11 = j11,
              x12 = j12,
              x13 = j13,
              x14 = j14,
              x15 = j15,
              u;
            for (var i = 0; i < 20; i += 2) {
              u = (x0 + x12) | 0;
              x4 ^= (u << 7) | (u >>> (32 - 7));
              u = (x4 + x0) | 0;
              x8 ^= (u << 9) | (u >>> (32 - 9));
              u = (x8 + x4) | 0;
              x12 ^= (u << 13) | (u >>> (32 - 13));
              u = (x12 + x8) | 0;
              x0 ^= (u << 18) | (u >>> (32 - 18));
              u = (x5 + x1) | 0;
              x9 ^= (u << 7) | (u >>> (32 - 7));
              u = (x9 + x5) | 0;
              x13 ^= (u << 9) | (u >>> (32 - 9));
              u = (x13 + x9) | 0;
              x1 ^= (u << 13) | (u >>> (32 - 13));
              u = (x1 + x13) | 0;
              x5 ^= (u << 18) | (u >>> (32 - 18));
              u = (x10 + x6) | 0;
              x14 ^= (u << 7) | (u >>> (32 - 7));
              u = (x14 + x10) | 0;
              x2 ^= (u << 9) | (u >>> (32 - 9));
              u = (x2 + x14) | 0;
              x6 ^= (u << 13) | (u >>> (32 - 13));
              u = (x6 + x2) | 0;
              x10 ^= (u << 18) | (u >>> (32 - 18));
              u = (x15 + x11) | 0;
              x3 ^= (u << 7) | (u >>> (32 - 7));
              u = (x3 + x15) | 0;
              x7 ^= (u << 9) | (u >>> (32 - 9));
              u = (x7 + x3) | 0;
              x11 ^= (u << 13) | (u >>> (32 - 13));
              u = (x11 + x7) | 0;
              x15 ^= (u << 18) | (u >>> (32 - 18));
              u = (x0 + x3) | 0;
              x1 ^= (u << 7) | (u >>> (32 - 7));
              u = (x1 + x0) | 0;
              x2 ^= (u << 9) | (u >>> (32 - 9));
              u = (x2 + x1) | 0;
              x3 ^= (u << 13) | (u >>> (32 - 13));
              u = (x3 + x2) | 0;
              x0 ^= (u << 18) | (u >>> (32 - 18));
              u = (x5 + x4) | 0;
              x6 ^= (u << 7) | (u >>> (32 - 7));
              u = (x6 + x5) | 0;
              x7 ^= (u << 9) | (u >>> (32 - 9));
              u = (x7 + x6) | 0;
              x4 ^= (u << 13) | (u >>> (32 - 13));
              u = (x4 + x7) | 0;
              x5 ^= (u << 18) | (u >>> (32 - 18));
              u = (x10 + x9) | 0;
              x11 ^= (u << 7) | (u >>> (32 - 7));
              u = (x11 + x10) | 0;
              x8 ^= (u << 9) | (u >>> (32 - 9));
              u = (x8 + x11) | 0;
              x9 ^= (u << 13) | (u >>> (32 - 13));
              u = (x9 + x8) | 0;
              x10 ^= (u << 18) | (u >>> (32 - 18));
              u = (x15 + x14) | 0;
              x12 ^= (u << 7) | (u >>> (32 - 7));
              u = (x12 + x15) | 0;
              x13 ^= (u << 9) | (u >>> (32 - 9));
              u = (x13 + x12) | 0;
              x14 ^= (u << 13) | (u >>> (32 - 13));
              u = (x14 + x13) | 0;
              x15 ^= (u << 18) | (u >>> (32 - 18));
            }
            x0 = (x0 + j0) | 0;
            x1 = (x1 + j1) | 0;
            x2 = (x2 + j2) | 0;
            x3 = (x3 + j3) | 0;
            x4 = (x4 + j4) | 0;
            x5 = (x5 + j5) | 0;
            x6 = (x6 + j6) | 0;
            x7 = (x7 + j7) | 0;
            x8 = (x8 + j8) | 0;
            x9 = (x9 + j9) | 0;
            x10 = (x10 + j10) | 0;
            x11 = (x11 + j11) | 0;
            x12 = (x12 + j12) | 0;
            x13 = (x13 + j13) | 0;
            x14 = (x14 + j14) | 0;
            x15 = (x15 + j15) | 0;
            o[0] = (x0 >>> 0) & 255;
            o[1] = (x0 >>> 8) & 255;
            o[2] = (x0 >>> 16) & 255;
            o[3] = (x0 >>> 24) & 255;
            o[4] = (x1 >>> 0) & 255;
            o[5] = (x1 >>> 8) & 255;
            o[6] = (x1 >>> 16) & 255;
            o[7] = (x1 >>> 24) & 255;
            o[8] = (x2 >>> 0) & 255;
            o[9] = (x2 >>> 8) & 255;
            o[10] = (x2 >>> 16) & 255;
            o[11] = (x2 >>> 24) & 255;
            o[12] = (x3 >>> 0) & 255;
            o[13] = (x3 >>> 8) & 255;
            o[14] = (x3 >>> 16) & 255;
            o[15] = (x3 >>> 24) & 255;
            o[16] = (x4 >>> 0) & 255;
            o[17] = (x4 >>> 8) & 255;
            o[18] = (x4 >>> 16) & 255;
            o[19] = (x4 >>> 24) & 255;
            o[20] = (x5 >>> 0) & 255;
            o[21] = (x5 >>> 8) & 255;
            o[22] = (x5 >>> 16) & 255;
            o[23] = (x5 >>> 24) & 255;
            o[24] = (x6 >>> 0) & 255;
            o[25] = (x6 >>> 8) & 255;
            o[26] = (x6 >>> 16) & 255;
            o[27] = (x6 >>> 24) & 255;
            o[28] = (x7 >>> 0) & 255;
            o[29] = (x7 >>> 8) & 255;
            o[30] = (x7 >>> 16) & 255;
            o[31] = (x7 >>> 24) & 255;
            o[32] = (x8 >>> 0) & 255;
            o[33] = (x8 >>> 8) & 255;
            o[34] = (x8 >>> 16) & 255;
            o[35] = (x8 >>> 24) & 255;
            o[36] = (x9 >>> 0) & 255;
            o[37] = (x9 >>> 8) & 255;
            o[38] = (x9 >>> 16) & 255;
            o[39] = (x9 >>> 24) & 255;
            o[40] = (x10 >>> 0) & 255;
            o[41] = (x10 >>> 8) & 255;
            o[42] = (x10 >>> 16) & 255;
            o[43] = (x10 >>> 24) & 255;
            o[44] = (x11 >>> 0) & 255;
            o[45] = (x11 >>> 8) & 255;
            o[46] = (x11 >>> 16) & 255;
            o[47] = (x11 >>> 24) & 255;
            o[48] = (x12 >>> 0) & 255;
            o[49] = (x12 >>> 8) & 255;
            o[50] = (x12 >>> 16) & 255;
            o[51] = (x12 >>> 24) & 255;
            o[52] = (x13 >>> 0) & 255;
            o[53] = (x13 >>> 8) & 255;
            o[54] = (x13 >>> 16) & 255;
            o[55] = (x13 >>> 24) & 255;
            o[56] = (x14 >>> 0) & 255;
            o[57] = (x14 >>> 8) & 255;
            o[58] = (x14 >>> 16) & 255;
            o[59] = (x14 >>> 24) & 255;
            o[60] = (x15 >>> 0) & 255;
            o[61] = (x15 >>> 8) & 255;
            o[62] = (x15 >>> 16) & 255;
            o[63] = (x15 >>> 24) & 255;
          }
          function core_hsalsa20(o, p, k, c) {
            var j0 =
                (c[0] & 255) |
                ((c[1] & 255) << 8) |
                ((c[2] & 255) << 16) |
                ((c[3] & 255) << 24),
              j1 =
                (k[0] & 255) |
                ((k[1] & 255) << 8) |
                ((k[2] & 255) << 16) |
                ((k[3] & 255) << 24),
              j2 =
                (k[4] & 255) |
                ((k[5] & 255) << 8) |
                ((k[6] & 255) << 16) |
                ((k[7] & 255) << 24),
              j3 =
                (k[8] & 255) |
                ((k[9] & 255) << 8) |
                ((k[10] & 255) << 16) |
                ((k[11] & 255) << 24),
              j4 =
                (k[12] & 255) |
                ((k[13] & 255) << 8) |
                ((k[14] & 255) << 16) |
                ((k[15] & 255) << 24),
              j5 =
                (c[4] & 255) |
                ((c[5] & 255) << 8) |
                ((c[6] & 255) << 16) |
                ((c[7] & 255) << 24),
              j6 =
                (p[0] & 255) |
                ((p[1] & 255) << 8) |
                ((p[2] & 255) << 16) |
                ((p[3] & 255) << 24),
              j7 =
                (p[4] & 255) |
                ((p[5] & 255) << 8) |
                ((p[6] & 255) << 16) |
                ((p[7] & 255) << 24),
              j8 =
                (p[8] & 255) |
                ((p[9] & 255) << 8) |
                ((p[10] & 255) << 16) |
                ((p[11] & 255) << 24),
              j9 =
                (p[12] & 255) |
                ((p[13] & 255) << 8) |
                ((p[14] & 255) << 16) |
                ((p[15] & 255) << 24),
              j10 =
                (c[8] & 255) |
                ((c[9] & 255) << 8) |
                ((c[10] & 255) << 16) |
                ((c[11] & 255) << 24),
              j11 =
                (k[16] & 255) |
                ((k[17] & 255) << 8) |
                ((k[18] & 255) << 16) |
                ((k[19] & 255) << 24),
              j12 =
                (k[20] & 255) |
                ((k[21] & 255) << 8) |
                ((k[22] & 255) << 16) |
                ((k[23] & 255) << 24),
              j13 =
                (k[24] & 255) |
                ((k[25] & 255) << 8) |
                ((k[26] & 255) << 16) |
                ((k[27] & 255) << 24),
              j14 =
                (k[28] & 255) |
                ((k[29] & 255) << 8) |
                ((k[30] & 255) << 16) |
                ((k[31] & 255) << 24),
              j15 =
                (c[12] & 255) |
                ((c[13] & 255) << 8) |
                ((c[14] & 255) << 16) |
                ((c[15] & 255) << 24);
            var x0 = j0,
              x1 = j1,
              x2 = j2,
              x3 = j3,
              x4 = j4,
              x5 = j5,
              x6 = j6,
              x7 = j7,
              x8 = j8,
              x9 = j9,
              x10 = j10,
              x11 = j11,
              x12 = j12,
              x13 = j13,
              x14 = j14,
              x15 = j15,
              u;
            for (var i = 0; i < 20; i += 2) {
              u = (x0 + x12) | 0;
              x4 ^= (u << 7) | (u >>> (32 - 7));
              u = (x4 + x0) | 0;
              x8 ^= (u << 9) | (u >>> (32 - 9));
              u = (x8 + x4) | 0;
              x12 ^= (u << 13) | (u >>> (32 - 13));
              u = (x12 + x8) | 0;
              x0 ^= (u << 18) | (u >>> (32 - 18));
              u = (x5 + x1) | 0;
              x9 ^= (u << 7) | (u >>> (32 - 7));
              u = (x9 + x5) | 0;
              x13 ^= (u << 9) | (u >>> (32 - 9));
              u = (x13 + x9) | 0;
              x1 ^= (u << 13) | (u >>> (32 - 13));
              u = (x1 + x13) | 0;
              x5 ^= (u << 18) | (u >>> (32 - 18));
              u = (x10 + x6) | 0;
              x14 ^= (u << 7) | (u >>> (32 - 7));
              u = (x14 + x10) | 0;
              x2 ^= (u << 9) | (u >>> (32 - 9));
              u = (x2 + x14) | 0;
              x6 ^= (u << 13) | (u >>> (32 - 13));
              u = (x6 + x2) | 0;
              x10 ^= (u << 18) | (u >>> (32 - 18));
              u = (x15 + x11) | 0;
              x3 ^= (u << 7) | (u >>> (32 - 7));
              u = (x3 + x15) | 0;
              x7 ^= (u << 9) | (u >>> (32 - 9));
              u = (x7 + x3) | 0;
              x11 ^= (u << 13) | (u >>> (32 - 13));
              u = (x11 + x7) | 0;
              x15 ^= (u << 18) | (u >>> (32 - 18));
              u = (x0 + x3) | 0;
              x1 ^= (u << 7) | (u >>> (32 - 7));
              u = (x1 + x0) | 0;
              x2 ^= (u << 9) | (u >>> (32 - 9));
              u = (x2 + x1) | 0;
              x3 ^= (u << 13) | (u >>> (32 - 13));
              u = (x3 + x2) | 0;
              x0 ^= (u << 18) | (u >>> (32 - 18));
              u = (x5 + x4) | 0;
              x6 ^= (u << 7) | (u >>> (32 - 7));
              u = (x6 + x5) | 0;
              x7 ^= (u << 9) | (u >>> (32 - 9));
              u = (x7 + x6) | 0;
              x4 ^= (u << 13) | (u >>> (32 - 13));
              u = (x4 + x7) | 0;
              x5 ^= (u << 18) | (u >>> (32 - 18));
              u = (x10 + x9) | 0;
              x11 ^= (u << 7) | (u >>> (32 - 7));
              u = (x11 + x10) | 0;
              x8 ^= (u << 9) | (u >>> (32 - 9));
              u = (x8 + x11) | 0;
              x9 ^= (u << 13) | (u >>> (32 - 13));
              u = (x9 + x8) | 0;
              x10 ^= (u << 18) | (u >>> (32 - 18));
              u = (x15 + x14) | 0;
              x12 ^= (u << 7) | (u >>> (32 - 7));
              u = (x12 + x15) | 0;
              x13 ^= (u << 9) | (u >>> (32 - 9));
              u = (x13 + x12) | 0;
              x14 ^= (u << 13) | (u >>> (32 - 13));
              u = (x14 + x13) | 0;
              x15 ^= (u << 18) | (u >>> (32 - 18));
            }
            o[0] = (x0 >>> 0) & 255;
            o[1] = (x0 >>> 8) & 255;
            o[2] = (x0 >>> 16) & 255;
            o[3] = (x0 >>> 24) & 255;
            o[4] = (x5 >>> 0) & 255;
            o[5] = (x5 >>> 8) & 255;
            o[6] = (x5 >>> 16) & 255;
            o[7] = (x5 >>> 24) & 255;
            o[8] = (x10 >>> 0) & 255;
            o[9] = (x10 >>> 8) & 255;
            o[10] = (x10 >>> 16) & 255;
            o[11] = (x10 >>> 24) & 255;
            o[12] = (x15 >>> 0) & 255;
            o[13] = (x15 >>> 8) & 255;
            o[14] = (x15 >>> 16) & 255;
            o[15] = (x15 >>> 24) & 255;
            o[16] = (x6 >>> 0) & 255;
            o[17] = (x6 >>> 8) & 255;
            o[18] = (x6 >>> 16) & 255;
            o[19] = (x6 >>> 24) & 255;
            o[20] = (x7 >>> 0) & 255;
            o[21] = (x7 >>> 8) & 255;
            o[22] = (x7 >>> 16) & 255;
            o[23] = (x7 >>> 24) & 255;
            o[24] = (x8 >>> 0) & 255;
            o[25] = (x8 >>> 8) & 255;
            o[26] = (x8 >>> 16) & 255;
            o[27] = (x8 >>> 24) & 255;
            o[28] = (x9 >>> 0) & 255;
            o[29] = (x9 >>> 8) & 255;
            o[30] = (x9 >>> 16) & 255;
            o[31] = (x9 >>> 24) & 255;
          }
          function crypto_core_salsa20(out, inp, k, c) {
            core_salsa20(out, inp, k, c);
          }
          function crypto_core_hsalsa20(out, inp, k, c) {
            core_hsalsa20(out, inp, k, c);
          }
          var sigma = new Uint8Array([
            101, 120, 112, 97, 110, 100, 32, 51, 50, 45, 98, 121, 116, 101, 32,
            107,
          ]);
          function crypto_stream_salsa20_xor(c, cpos, m, mpos, b, n, k) {
            var z = new Uint8Array(16),
              x = new Uint8Array(64);
            var u, i;
            for (i = 0; i < 16; i++) z[i] = 0;
            for (i = 0; i < 8; i++) z[i] = n[i];
            while (b >= 64) {
              crypto_core_salsa20(x, z, k, sigma);
              for (i = 0; i < 64; i++) c[cpos + i] = m[mpos + i] ^ x[i];
              u = 1;
              for (i = 8; i < 16; i++) {
                u = (u + (z[i] & 255)) | 0;
                z[i] = u & 255;
                u >>>= 8;
              }
              b -= 64;
              cpos += 64;
              mpos += 64;
            }
            if (b > 0) {
              crypto_core_salsa20(x, z, k, sigma);
              for (i = 0; i < b; i++) c[cpos + i] = m[mpos + i] ^ x[i];
            }
            return 0;
          }
          function crypto_stream_salsa20(c, cpos, b, n, k) {
            var z = new Uint8Array(16),
              x = new Uint8Array(64);
            var u, i;
            for (i = 0; i < 16; i++) z[i] = 0;
            for (i = 0; i < 8; i++) z[i] = n[i];
            while (b >= 64) {
              crypto_core_salsa20(x, z, k, sigma);
              for (i = 0; i < 64; i++) c[cpos + i] = x[i];
              u = 1;
              for (i = 8; i < 16; i++) {
                u = (u + (z[i] & 255)) | 0;
                z[i] = u & 255;
                u >>>= 8;
              }
              b -= 64;
              cpos += 64;
            }
            if (b > 0) {
              crypto_core_salsa20(x, z, k, sigma);
              for (i = 0; i < b; i++) c[cpos + i] = x[i];
            }
            return 0;
          }
          function crypto_stream(c, cpos, d, n, k) {
            var s = new Uint8Array(32);
            crypto_core_hsalsa20(s, n, k, sigma);
            var sn = new Uint8Array(8);
            for (var i = 0; i < 8; i++) sn[i] = n[i + 16];
            return crypto_stream_salsa20(c, cpos, d, sn, s);
          }
          function crypto_stream_xor(c, cpos, m, mpos, d, n, k) {
            var s = new Uint8Array(32);
            crypto_core_hsalsa20(s, n, k, sigma);
            var sn = new Uint8Array(8);
            for (var i = 0; i < 8; i++) sn[i] = n[i + 16];
            return crypto_stream_salsa20_xor(c, cpos, m, mpos, d, sn, s);
          }
          var poly1305 = function (key) {
            this.buffer = new Uint8Array(16);
            this.r = new Uint16Array(10);
            this.h = new Uint16Array(10);
            this.pad = new Uint16Array(8);
            this.leftover = 0;
            this.fin = 0;
            var t0, t1, t2, t3, t4, t5, t6, t7;
            t0 = (key[0] & 255) | ((key[1] & 255) << 8);
            this.r[0] = t0 & 8191;
            t1 = (key[2] & 255) | ((key[3] & 255) << 8);
            this.r[1] = ((t0 >>> 13) | (t1 << 3)) & 8191;
            t2 = (key[4] & 255) | ((key[5] & 255) << 8);
            this.r[2] = ((t1 >>> 10) | (t2 << 6)) & 7939;
            t3 = (key[6] & 255) | ((key[7] & 255) << 8);
            this.r[3] = ((t2 >>> 7) | (t3 << 9)) & 8191;
            t4 = (key[8] & 255) | ((key[9] & 255) << 8);
            this.r[4] = ((t3 >>> 4) | (t4 << 12)) & 255;
            this.r[5] = (t4 >>> 1) & 8190;
            t5 = (key[10] & 255) | ((key[11] & 255) << 8);
            this.r[6] = ((t4 >>> 14) | (t5 << 2)) & 8191;
            t6 = (key[12] & 255) | ((key[13] & 255) << 8);
            this.r[7] = ((t5 >>> 11) | (t6 << 5)) & 8065;
            t7 = (key[14] & 255) | ((key[15] & 255) << 8);
            this.r[8] = ((t6 >>> 8) | (t7 << 8)) & 8191;
            this.r[9] = (t7 >>> 5) & 127;
            this.pad[0] = (key[16] & 255) | ((key[17] & 255) << 8);
            this.pad[1] = (key[18] & 255) | ((key[19] & 255) << 8);
            this.pad[2] = (key[20] & 255) | ((key[21] & 255) << 8);
            this.pad[3] = (key[22] & 255) | ((key[23] & 255) << 8);
            this.pad[4] = (key[24] & 255) | ((key[25] & 255) << 8);
            this.pad[5] = (key[26] & 255) | ((key[27] & 255) << 8);
            this.pad[6] = (key[28] & 255) | ((key[29] & 255) << 8);
            this.pad[7] = (key[30] & 255) | ((key[31] & 255) << 8);
          };
          poly1305.prototype.blocks = function (m, mpos, bytes) {
            var hibit = this.fin ? 0 : 1 << 11;
            var t0, t1, t2, t3, t4, t5, t6, t7, c;
            var d0, d1, d2, d3, d4, d5, d6, d7, d8, d9;
            var h0 = this.h[0],
              h1 = this.h[1],
              h2 = this.h[2],
              h3 = this.h[3],
              h4 = this.h[4],
              h5 = this.h[5],
              h6 = this.h[6],
              h7 = this.h[7],
              h8 = this.h[8],
              h9 = this.h[9];
            var r0 = this.r[0],
              r1 = this.r[1],
              r2 = this.r[2],
              r3 = this.r[3],
              r4 = this.r[4],
              r5 = this.r[5],
              r6 = this.r[6],
              r7 = this.r[7],
              r8 = this.r[8],
              r9 = this.r[9];
            while (bytes >= 16) {
              t0 = (m[mpos + 0] & 255) | ((m[mpos + 1] & 255) << 8);
              h0 += t0 & 8191;
              t1 = (m[mpos + 2] & 255) | ((m[mpos + 3] & 255) << 8);
              h1 += ((t0 >>> 13) | (t1 << 3)) & 8191;
              t2 = (m[mpos + 4] & 255) | ((m[mpos + 5] & 255) << 8);
              h2 += ((t1 >>> 10) | (t2 << 6)) & 8191;
              t3 = (m[mpos + 6] & 255) | ((m[mpos + 7] & 255) << 8);
              h3 += ((t2 >>> 7) | (t3 << 9)) & 8191;
              t4 = (m[mpos + 8] & 255) | ((m[mpos + 9] & 255) << 8);
              h4 += ((t3 >>> 4) | (t4 << 12)) & 8191;
              h5 += (t4 >>> 1) & 8191;
              t5 = (m[mpos + 10] & 255) | ((m[mpos + 11] & 255) << 8);
              h6 += ((t4 >>> 14) | (t5 << 2)) & 8191;
              t6 = (m[mpos + 12] & 255) | ((m[mpos + 13] & 255) << 8);
              h7 += ((t5 >>> 11) | (t6 << 5)) & 8191;
              t7 = (m[mpos + 14] & 255) | ((m[mpos + 15] & 255) << 8);
              h8 += ((t6 >>> 8) | (t7 << 8)) & 8191;
              h9 += (t7 >>> 5) | hibit;
              c = 0;
              d0 = c;
              d0 += h0 * r0;
              d0 += h1 * (5 * r9);
              d0 += h2 * (5 * r8);
              d0 += h3 * (5 * r7);
              d0 += h4 * (5 * r6);
              c = d0 >>> 13;
              d0 &= 8191;
              d0 += h5 * (5 * r5);
              d0 += h6 * (5 * r4);
              d0 += h7 * (5 * r3);
              d0 += h8 * (5 * r2);
              d0 += h9 * (5 * r1);
              c += d0 >>> 13;
              d0 &= 8191;
              d1 = c;
              d1 += h0 * r1;
              d1 += h1 * r0;
              d1 += h2 * (5 * r9);
              d1 += h3 * (5 * r8);
              d1 += h4 * (5 * r7);
              c = d1 >>> 13;
              d1 &= 8191;
              d1 += h5 * (5 * r6);
              d1 += h6 * (5 * r5);
              d1 += h7 * (5 * r4);
              d1 += h8 * (5 * r3);
              d1 += h9 * (5 * r2);
              c += d1 >>> 13;
              d1 &= 8191;
              d2 = c;
              d2 += h0 * r2;
              d2 += h1 * r1;
              d2 += h2 * r0;
              d2 += h3 * (5 * r9);
              d2 += h4 * (5 * r8);
              c = d2 >>> 13;
              d2 &= 8191;
              d2 += h5 * (5 * r7);
              d2 += h6 * (5 * r6);
              d2 += h7 * (5 * r5);
              d2 += h8 * (5 * r4);
              d2 += h9 * (5 * r3);
              c += d2 >>> 13;
              d2 &= 8191;
              d3 = c;
              d3 += h0 * r3;
              d3 += h1 * r2;
              d3 += h2 * r1;
              d3 += h3 * r0;
              d3 += h4 * (5 * r9);
              c = d3 >>> 13;
              d3 &= 8191;
              d3 += h5 * (5 * r8);
              d3 += h6 * (5 * r7);
              d3 += h7 * (5 * r6);
              d3 += h8 * (5 * r5);
              d3 += h9 * (5 * r4);
              c += d3 >>> 13;
              d3 &= 8191;
              d4 = c;
              d4 += h0 * r4;
              d4 += h1 * r3;
              d4 += h2 * r2;
              d4 += h3 * r1;
              d4 += h4 * r0;
              c = d4 >>> 13;
              d4 &= 8191;
              d4 += h5 * (5 * r9);
              d4 += h6 * (5 * r8);
              d4 += h7 * (5 * r7);
              d4 += h8 * (5 * r6);
              d4 += h9 * (5 * r5);
              c += d4 >>> 13;
              d4 &= 8191;
              d5 = c;
              d5 += h0 * r5;
              d5 += h1 * r4;
              d5 += h2 * r3;
              d5 += h3 * r2;
              d5 += h4 * r1;
              c = d5 >>> 13;
              d5 &= 8191;
              d5 += h5 * r0;
              d5 += h6 * (5 * r9);
              d5 += h7 * (5 * r8);
              d5 += h8 * (5 * r7);
              d5 += h9 * (5 * r6);
              c += d5 >>> 13;
              d5 &= 8191;
              d6 = c;
              d6 += h0 * r6;
              d6 += h1 * r5;
              d6 += h2 * r4;
              d6 += h3 * r3;
              d6 += h4 * r2;
              c = d6 >>> 13;
              d6 &= 8191;
              d6 += h5 * r1;
              d6 += h6 * r0;
              d6 += h7 * (5 * r9);
              d6 += h8 * (5 * r8);
              d6 += h9 * (5 * r7);
              c += d6 >>> 13;
              d6 &= 8191;
              d7 = c;
              d7 += h0 * r7;
              d7 += h1 * r6;
              d7 += h2 * r5;
              d7 += h3 * r4;
              d7 += h4 * r3;
              c = d7 >>> 13;
              d7 &= 8191;
              d7 += h5 * r2;
              d7 += h6 * r1;
              d7 += h7 * r0;
              d7 += h8 * (5 * r9);
              d7 += h9 * (5 * r8);
              c += d7 >>> 13;
              d7 &= 8191;
              d8 = c;
              d8 += h0 * r8;
              d8 += h1 * r7;
              d8 += h2 * r6;
              d8 += h3 * r5;
              d8 += h4 * r4;
              c = d8 >>> 13;
              d8 &= 8191;
              d8 += h5 * r3;
              d8 += h6 * r2;
              d8 += h7 * r1;
              d8 += h8 * r0;
              d8 += h9 * (5 * r9);
              c += d8 >>> 13;
              d8 &= 8191;
              d9 = c;
              d9 += h0 * r9;
              d9 += h1 * r8;
              d9 += h2 * r7;
              d9 += h3 * r6;
              d9 += h4 * r5;
              c = d9 >>> 13;
              d9 &= 8191;
              d9 += h5 * r4;
              d9 += h6 * r3;
              d9 += h7 * r2;
              d9 += h8 * r1;
              d9 += h9 * r0;
              c += d9 >>> 13;
              d9 &= 8191;
              c = ((c << 2) + c) | 0;
              c = (c + d0) | 0;
              d0 = c & 8191;
              c = c >>> 13;
              d1 += c;
              h0 = d0;
              h1 = d1;
              h2 = d2;
              h3 = d3;
              h4 = d4;
              h5 = d5;
              h6 = d6;
              h7 = d7;
              h8 = d8;
              h9 = d9;
              mpos += 16;
              bytes -= 16;
            }
            this.h[0] = h0;
            this.h[1] = h1;
            this.h[2] = h2;
            this.h[3] = h3;
            this.h[4] = h4;
            this.h[5] = h5;
            this.h[6] = h6;
            this.h[7] = h7;
            this.h[8] = h8;
            this.h[9] = h9;
          };
          poly1305.prototype.finish = function (mac, macpos) {
            var g = new Uint16Array(10);
            var c, mask, f, i;
            if (this.leftover) {
              i = this.leftover;
              this.buffer[i++] = 1;
              for (; i < 16; i++) this.buffer[i] = 0;
              this.fin = 1;
              this.blocks(this.buffer, 0, 16);
            }
            c = this.h[1] >>> 13;
            this.h[1] &= 8191;
            for (i = 2; i < 10; i++) {
              this.h[i] += c;
              c = this.h[i] >>> 13;
              this.h[i] &= 8191;
            }
            this.h[0] += c * 5;
            c = this.h[0] >>> 13;
            this.h[0] &= 8191;
            this.h[1] += c;
            c = this.h[1] >>> 13;
            this.h[1] &= 8191;
            this.h[2] += c;
            g[0] = this.h[0] + 5;
            c = g[0] >>> 13;
            g[0] &= 8191;
            for (i = 1; i < 10; i++) {
              g[i] = this.h[i] + c;
              c = g[i] >>> 13;
              g[i] &= 8191;
            }
            g[9] -= 1 << 13;
            mask = (c ^ 1) - 1;
            for (i = 0; i < 10; i++) g[i] &= mask;
            mask = ~mask;
            for (i = 0; i < 10; i++) this.h[i] = (this.h[i] & mask) | g[i];
            this.h[0] = (this.h[0] | (this.h[1] << 13)) & 65535;
            this.h[1] = ((this.h[1] >>> 3) | (this.h[2] << 10)) & 65535;
            this.h[2] = ((this.h[2] >>> 6) | (this.h[3] << 7)) & 65535;
            this.h[3] = ((this.h[3] >>> 9) | (this.h[4] << 4)) & 65535;
            this.h[4] =
              ((this.h[4] >>> 12) | (this.h[5] << 1) | (this.h[6] << 14)) &
              65535;
            this.h[5] = ((this.h[6] >>> 2) | (this.h[7] << 11)) & 65535;
            this.h[6] = ((this.h[7] >>> 5) | (this.h[8] << 8)) & 65535;
            this.h[7] = ((this.h[8] >>> 8) | (this.h[9] << 5)) & 65535;
            f = this.h[0] + this.pad[0];
            this.h[0] = f & 65535;
            for (i = 1; i < 8; i++) {
              f = (((this.h[i] + this.pad[i]) | 0) + (f >>> 16)) | 0;
              this.h[i] = f & 65535;
            }
            mac[macpos + 0] = (this.h[0] >>> 0) & 255;
            mac[macpos + 1] = (this.h[0] >>> 8) & 255;
            mac[macpos + 2] = (this.h[1] >>> 0) & 255;
            mac[macpos + 3] = (this.h[1] >>> 8) & 255;
            mac[macpos + 4] = (this.h[2] >>> 0) & 255;
            mac[macpos + 5] = (this.h[2] >>> 8) & 255;
            mac[macpos + 6] = (this.h[3] >>> 0) & 255;
            mac[macpos + 7] = (this.h[3] >>> 8) & 255;
            mac[macpos + 8] = (this.h[4] >>> 0) & 255;
            mac[macpos + 9] = (this.h[4] >>> 8) & 255;
            mac[macpos + 10] = (this.h[5] >>> 0) & 255;
            mac[macpos + 11] = (this.h[5] >>> 8) & 255;
            mac[macpos + 12] = (this.h[6] >>> 0) & 255;
            mac[macpos + 13] = (this.h[6] >>> 8) & 255;
            mac[macpos + 14] = (this.h[7] >>> 0) & 255;
            mac[macpos + 15] = (this.h[7] >>> 8) & 255;
          };
          poly1305.prototype.update = function (m, mpos, bytes) {
            var i, want;
            if (this.leftover) {
              want = 16 - this.leftover;
              if (want > bytes) want = bytes;
              for (i = 0; i < want; i++)
                this.buffer[this.leftover + i] = m[mpos + i];
              bytes -= want;
              mpos += want;
              this.leftover += want;
              if (this.leftover < 16) return;
              this.blocks(this.buffer, 0, 16);
              this.leftover = 0;
            }
            if (bytes >= 16) {
              want = bytes - (bytes % 16);
              this.blocks(m, mpos, want);
              mpos += want;
              bytes -= want;
            }
            if (bytes) {
              for (i = 0; i < bytes; i++)
                this.buffer[this.leftover + i] = m[mpos + i];
              this.leftover += bytes;
            }
          };
          function crypto_onetimeauth(out, outpos, m, mpos, n, k) {
            var s = new poly1305(k);
            s.update(m, mpos, n);
            s.finish(out, outpos);
            return 0;
          }
          function crypto_onetimeauth_verify(h, hpos, m, mpos, n, k) {
            var x = new Uint8Array(16);
            crypto_onetimeauth(x, 0, m, mpos, n, k);
            return crypto_verify_16(h, hpos, x, 0);
          }
          function crypto_secretbox(c, m, d, n, k) {
            var i;
            if (d < 32) return -1;
            crypto_stream_xor(c, 0, m, 0, d, n, k);
            crypto_onetimeauth(c, 16, c, 32, d - 32, c);
            for (i = 0; i < 16; i++) c[i] = 0;
            return 0;
          }
          function crypto_secretbox_open(m, c, d, n, k) {
            var i;
            var x = new Uint8Array(32);
            if (d < 32) return -1;
            crypto_stream(x, 0, 32, n, k);
            if (crypto_onetimeauth_verify(c, 16, c, 32, d - 32, x) !== 0)
              return -1;
            crypto_stream_xor(m, 0, c, 0, d, n, k);
            for (i = 0; i < 32; i++) m[i] = 0;
            return 0;
          }
          function set25519(r, a) {
            var i;
            for (i = 0; i < 16; i++) r[i] = a[i] | 0;
          }
          function car25519(o) {
            var i,
              v,
              c = 1;
            for (i = 0; i < 16; i++) {
              v = o[i] + c + 65535;
              c = Math.floor(v / 65536);
              o[i] = v - c * 65536;
            }
            o[0] += c - 1 + 37 * (c - 1);
          }
          function sel25519(p, q, b) {
            var t,
              c = ~(b - 1);
            for (var i = 0; i < 16; i++) {
              t = c & (p[i] ^ q[i]);
              p[i] ^= t;
              q[i] ^= t;
            }
          }
          function pack25519(o, n) {
            var i, j, b;
            var m = gf(),
              t = gf();
            for (i = 0; i < 16; i++) t[i] = n[i];
            car25519(t);
            car25519(t);
            car25519(t);
            for (j = 0; j < 2; j++) {
              m[0] = t[0] - 65517;
              for (i = 1; i < 15; i++) {
                m[i] = t[i] - 65535 - ((m[i - 1] >> 16) & 1);
                m[i - 1] &= 65535;
              }
              m[15] = t[15] - 32767 - ((m[14] >> 16) & 1);
              b = (m[15] >> 16) & 1;
              m[14] &= 65535;
              sel25519(t, m, 1 - b);
            }
            for (i = 0; i < 16; i++) {
              o[2 * i] = t[i] & 255;
              o[2 * i + 1] = t[i] >> 8;
            }
          }
          function neq25519(a, b) {
            var c = new Uint8Array(32),
              d = new Uint8Array(32);
            pack25519(c, a);
            pack25519(d, b);
            return crypto_verify_32(c, 0, d, 0);
          }
          function par25519(a) {
            var d = new Uint8Array(32);
            pack25519(d, a);
            return d[0] & 1;
          }
          function unpack25519(o, n) {
            var i;
            for (i = 0; i < 16; i++) o[i] = n[2 * i] + (n[2 * i + 1] << 8);
            o[15] &= 32767;
          }
          function A(o, a, b) {
            for (var i = 0; i < 16; i++) o[i] = a[i] + b[i];
          }
          function Z(o, a, b) {
            for (var i = 0; i < 16; i++) o[i] = a[i] - b[i];
          }
          function M(o, a, b) {
            var v,
              c,
              t0 = 0,
              t1 = 0,
              t2 = 0,
              t3 = 0,
              t4 = 0,
              t5 = 0,
              t6 = 0,
              t7 = 0,
              t8 = 0,
              t9 = 0,
              t10 = 0,
              t11 = 0,
              t12 = 0,
              t13 = 0,
              t14 = 0,
              t15 = 0,
              t16 = 0,
              t17 = 0,
              t18 = 0,
              t19 = 0,
              t20 = 0,
              t21 = 0,
              t22 = 0,
              t23 = 0,
              t24 = 0,
              t25 = 0,
              t26 = 0,
              t27 = 0,
              t28 = 0,
              t29 = 0,
              t30 = 0,
              b0 = b[0],
              b1 = b[1],
              b2 = b[2],
              b3 = b[3],
              b4 = b[4],
              b5 = b[5],
              b6 = b[6],
              b7 = b[7],
              b8 = b[8],
              b9 = b[9],
              b10 = b[10],
              b11 = b[11],
              b12 = b[12],
              b13 = b[13],
              b14 = b[14],
              b15 = b[15];
            v = a[0];
            t0 += v * b0;
            t1 += v * b1;
            t2 += v * b2;
            t3 += v * b3;
            t4 += v * b4;
            t5 += v * b5;
            t6 += v * b6;
            t7 += v * b7;
            t8 += v * b8;
            t9 += v * b9;
            t10 += v * b10;
            t11 += v * b11;
            t12 += v * b12;
            t13 += v * b13;
            t14 += v * b14;
            t15 += v * b15;
            v = a[1];
            t1 += v * b0;
            t2 += v * b1;
            t3 += v * b2;
            t4 += v * b3;
            t5 += v * b4;
            t6 += v * b5;
            t7 += v * b6;
            t8 += v * b7;
            t9 += v * b8;
            t10 += v * b9;
            t11 += v * b10;
            t12 += v * b11;
            t13 += v * b12;
            t14 += v * b13;
            t15 += v * b14;
            t16 += v * b15;
            v = a[2];
            t2 += v * b0;
            t3 += v * b1;
            t4 += v * b2;
            t5 += v * b3;
            t6 += v * b4;
            t7 += v * b5;
            t8 += v * b6;
            t9 += v * b7;
            t10 += v * b8;
            t11 += v * b9;
            t12 += v * b10;
            t13 += v * b11;
            t14 += v * b12;
            t15 += v * b13;
            t16 += v * b14;
            t17 += v * b15;
            v = a[3];
            t3 += v * b0;
            t4 += v * b1;
            t5 += v * b2;
            t6 += v * b3;
            t7 += v * b4;
            t8 += v * b5;
            t9 += v * b6;
            t10 += v * b7;
            t11 += v * b8;
            t12 += v * b9;
            t13 += v * b10;
            t14 += v * b11;
            t15 += v * b12;
            t16 += v * b13;
            t17 += v * b14;
            t18 += v * b15;
            v = a[4];
            t4 += v * b0;
            t5 += v * b1;
            t6 += v * b2;
            t7 += v * b3;
            t8 += v * b4;
            t9 += v * b5;
            t10 += v * b6;
            t11 += v * b7;
            t12 += v * b8;
            t13 += v * b9;
            t14 += v * b10;
            t15 += v * b11;
            t16 += v * b12;
            t17 += v * b13;
            t18 += v * b14;
            t19 += v * b15;
            v = a[5];
            t5 += v * b0;
            t6 += v * b1;
            t7 += v * b2;
            t8 += v * b3;
            t9 += v * b4;
            t10 += v * b5;
            t11 += v * b6;
            t12 += v * b7;
            t13 += v * b8;
            t14 += v * b9;
            t15 += v * b10;
            t16 += v * b11;
            t17 += v * b12;
            t18 += v * b13;
            t19 += v * b14;
            t20 += v * b15;
            v = a[6];
            t6 += v * b0;
            t7 += v * b1;
            t8 += v * b2;
            t9 += v * b3;
            t10 += v * b4;
            t11 += v * b5;
            t12 += v * b6;
            t13 += v * b7;
            t14 += v * b8;
            t15 += v * b9;
            t16 += v * b10;
            t17 += v * b11;
            t18 += v * b12;
            t19 += v * b13;
            t20 += v * b14;
            t21 += v * b15;
            v = a[7];
            t7 += v * b0;
            t8 += v * b1;
            t9 += v * b2;
            t10 += v * b3;
            t11 += v * b4;
            t12 += v * b5;
            t13 += v * b6;
            t14 += v * b7;
            t15 += v * b8;
            t16 += v * b9;
            t17 += v * b10;
            t18 += v * b11;
            t19 += v * b12;
            t20 += v * b13;
            t21 += v * b14;
            t22 += v * b15;
            v = a[8];
            t8 += v * b0;
            t9 += v * b1;
            t10 += v * b2;
            t11 += v * b3;
            t12 += v * b4;
            t13 += v * b5;
            t14 += v * b6;
            t15 += v * b7;
            t16 += v * b8;
            t17 += v * b9;
            t18 += v * b10;
            t19 += v * b11;
            t20 += v * b12;
            t21 += v * b13;
            t22 += v * b14;
            t23 += v * b15;
            v = a[9];
            t9 += v * b0;
            t10 += v * b1;
            t11 += v * b2;
            t12 += v * b3;
            t13 += v * b4;
            t14 += v * b5;
            t15 += v * b6;
            t16 += v * b7;
            t17 += v * b8;
            t18 += v * b9;
            t19 += v * b10;
            t20 += v * b11;
            t21 += v * b12;
            t22 += v * b13;
            t23 += v * b14;
            t24 += v * b15;
            v = a[10];
            t10 += v * b0;
            t11 += v * b1;
            t12 += v * b2;
            t13 += v * b3;
            t14 += v * b4;
            t15 += v * b5;
            t16 += v * b6;
            t17 += v * b7;
            t18 += v * b8;
            t19 += v * b9;
            t20 += v * b10;
            t21 += v * b11;
            t22 += v * b12;
            t23 += v * b13;
            t24 += v * b14;
            t25 += v * b15;
            v = a[11];
            t11 += v * b0;
            t12 += v * b1;
            t13 += v * b2;
            t14 += v * b3;
            t15 += v * b4;
            t16 += v * b5;
            t17 += v * b6;
            t18 += v * b7;
            t19 += v * b8;
            t20 += v * b9;
            t21 += v * b10;
            t22 += v * b11;
            t23 += v * b12;
            t24 += v * b13;
            t25 += v * b14;
            t26 += v * b15;
            v = a[12];
            t12 += v * b0;
            t13 += v * b1;
            t14 += v * b2;
            t15 += v * b3;
            t16 += v * b4;
            t17 += v * b5;
            t18 += v * b6;
            t19 += v * b7;
            t20 += v * b8;
            t21 += v * b9;
            t22 += v * b10;
            t23 += v * b11;
            t24 += v * b12;
            t25 += v * b13;
            t26 += v * b14;
            t27 += v * b15;
            v = a[13];
            t13 += v * b0;
            t14 += v * b1;
            t15 += v * b2;
            t16 += v * b3;
            t17 += v * b4;
            t18 += v * b5;
            t19 += v * b6;
            t20 += v * b7;
            t21 += v * b8;
            t22 += v * b9;
            t23 += v * b10;
            t24 += v * b11;
            t25 += v * b12;
            t26 += v * b13;
            t27 += v * b14;
            t28 += v * b15;
            v = a[14];
            t14 += v * b0;
            t15 += v * b1;
            t16 += v * b2;
            t17 += v * b3;
            t18 += v * b4;
            t19 += v * b5;
            t20 += v * b6;
            t21 += v * b7;
            t22 += v * b8;
            t23 += v * b9;
            t24 += v * b10;
            t25 += v * b11;
            t26 += v * b12;
            t27 += v * b13;
            t28 += v * b14;
            t29 += v * b15;
            v = a[15];
            t15 += v * b0;
            t16 += v * b1;
            t17 += v * b2;
            t18 += v * b3;
            t19 += v * b4;
            t20 += v * b5;
            t21 += v * b6;
            t22 += v * b7;
            t23 += v * b8;
            t24 += v * b9;
            t25 += v * b10;
            t26 += v * b11;
            t27 += v * b12;
            t28 += v * b13;
            t29 += v * b14;
            t30 += v * b15;
            t0 += 38 * t16;
            t1 += 38 * t17;
            t2 += 38 * t18;
            t3 += 38 * t19;
            t4 += 38 * t20;
            t5 += 38 * t21;
            t6 += 38 * t22;
            t7 += 38 * t23;
            t8 += 38 * t24;
            t9 += 38 * t25;
            t10 += 38 * t26;
            t11 += 38 * t27;
            t12 += 38 * t28;
            t13 += 38 * t29;
            t14 += 38 * t30;
            c = 1;
            v = t0 + c + 65535;
            c = Math.floor(v / 65536);
            t0 = v - c * 65536;
            v = t1 + c + 65535;
            c = Math.floor(v / 65536);
            t1 = v - c * 65536;
            v = t2 + c + 65535;
            c = Math.floor(v / 65536);
            t2 = v - c * 65536;
            v = t3 + c + 65535;
            c = Math.floor(v / 65536);
            t3 = v - c * 65536;
            v = t4 + c + 65535;
            c = Math.floor(v / 65536);
            t4 = v - c * 65536;
            v = t5 + c + 65535;
            c = Math.floor(v / 65536);
            t5 = v - c * 65536;
            v = t6 + c + 65535;
            c = Math.floor(v / 65536);
            t6 = v - c * 65536;
            v = t7 + c + 65535;
            c = Math.floor(v / 65536);
            t7 = v - c * 65536;
            v = t8 + c + 65535;
            c = Math.floor(v / 65536);
            t8 = v - c * 65536;
            v = t9 + c + 65535;
            c = Math.floor(v / 65536);
            t9 = v - c * 65536;
            v = t10 + c + 65535;
            c = Math.floor(v / 65536);
            t10 = v - c * 65536;
            v = t11 + c + 65535;
            c = Math.floor(v / 65536);
            t11 = v - c * 65536;
            v = t12 + c + 65535;
            c = Math.floor(v / 65536);
            t12 = v - c * 65536;
            v = t13 + c + 65535;
            c = Math.floor(v / 65536);
            t13 = v - c * 65536;
            v = t14 + c + 65535;
            c = Math.floor(v / 65536);
            t14 = v - c * 65536;
            v = t15 + c + 65535;
            c = Math.floor(v / 65536);
            t15 = v - c * 65536;
            t0 += c - 1 + 37 * (c - 1);
            c = 1;
            v = t0 + c + 65535;
            c = Math.floor(v / 65536);
            t0 = v - c * 65536;
            v = t1 + c + 65535;
            c = Math.floor(v / 65536);
            t1 = v - c * 65536;
            v = t2 + c + 65535;
            c = Math.floor(v / 65536);
            t2 = v - c * 65536;
            v = t3 + c + 65535;
            c = Math.floor(v / 65536);
            t3 = v - c * 65536;
            v = t4 + c + 65535;
            c = Math.floor(v / 65536);
            t4 = v - c * 65536;
            v = t5 + c + 65535;
            c = Math.floor(v / 65536);
            t5 = v - c * 65536;
            v = t6 + c + 65535;
            c = Math.floor(v / 65536);
            t6 = v - c * 65536;
            v = t7 + c + 65535;
            c = Math.floor(v / 65536);
            t7 = v - c * 65536;
            v = t8 + c + 65535;
            c = Math.floor(v / 65536);
            t8 = v - c * 65536;
            v = t9 + c + 65535;
            c = Math.floor(v / 65536);
            t9 = v - c * 65536;
            v = t10 + c + 65535;
            c = Math.floor(v / 65536);
            t10 = v - c * 65536;
            v = t11 + c + 65535;
            c = Math.floor(v / 65536);
            t11 = v - c * 65536;
            v = t12 + c + 65535;
            c = Math.floor(v / 65536);
            t12 = v - c * 65536;
            v = t13 + c + 65535;
            c = Math.floor(v / 65536);
            t13 = v - c * 65536;
            v = t14 + c + 65535;
            c = Math.floor(v / 65536);
            t14 = v - c * 65536;
            v = t15 + c + 65535;
            c = Math.floor(v / 65536);
            t15 = v - c * 65536;
            t0 += c - 1 + 37 * (c - 1);
            o[0] = t0;
            o[1] = t1;
            o[2] = t2;
            o[3] = t3;
            o[4] = t4;
            o[5] = t5;
            o[6] = t6;
            o[7] = t7;
            o[8] = t8;
            o[9] = t9;
            o[10] = t10;
            o[11] = t11;
            o[12] = t12;
            o[13] = t13;
            o[14] = t14;
            o[15] = t15;
          }
          function S(o, a) {
            M(o, a, a);
          }
          function inv25519(o, i) {
            var c = gf();
            var a;
            for (a = 0; a < 16; a++) c[a] = i[a];
            for (a = 253; a >= 0; a--) {
              S(c, c);
              if (a !== 2 && a !== 4) M(c, c, i);
            }
            for (a = 0; a < 16; a++) o[a] = c[a];
          }
          function pow2523(o, i) {
            var c = gf();
            var a;
            for (a = 0; a < 16; a++) c[a] = i[a];
            for (a = 250; a >= 0; a--) {
              S(c, c);
              if (a !== 1) M(c, c, i);
            }
            for (a = 0; a < 16; a++) o[a] = c[a];
          }
          function crypto_scalarmult(q, n, p) {
            var z = new Uint8Array(32);
            var x = new Float64Array(80),
              r,
              i;
            var a = gf(),
              b = gf(),
              c = gf(),
              d = gf(),
              e = gf(),
              f = gf();
            for (i = 0; i < 31; i++) z[i] = n[i];
            z[31] = (n[31] & 127) | 64;
            z[0] &= 248;
            unpack25519(x, p);
            for (i = 0; i < 16; i++) {
              b[i] = x[i];
              d[i] = a[i] = c[i] = 0;
            }
            a[0] = d[0] = 1;
            for (i = 254; i >= 0; --i) {
              r = (z[i >>> 3] >>> (i & 7)) & 1;
              sel25519(a, b, r);
              sel25519(c, d, r);
              A(e, a, c);
              Z(a, a, c);
              A(c, b, d);
              Z(b, b, d);
              S(d, e);
              S(f, a);
              M(a, c, a);
              M(c, b, e);
              A(e, a, c);
              Z(a, a, c);
              S(b, a);
              Z(c, d, f);
              M(a, c, _121665);
              A(a, a, d);
              M(c, c, a);
              M(a, d, f);
              M(d, b, x);
              S(b, e);
              sel25519(a, b, r);
              sel25519(c, d, r);
            }
            for (i = 0; i < 16; i++) {
              x[i + 16] = a[i];
              x[i + 32] = c[i];
              x[i + 48] = b[i];
              x[i + 64] = d[i];
            }
            var x32 = x.subarray(32);
            var x16 = x.subarray(16);
            inv25519(x32, x32);
            M(x16, x16, x32);
            pack25519(q, x16);
            return 0;
          }
          function crypto_scalarmult_base(q, n) {
            return crypto_scalarmult(q, n, _9);
          }
          function crypto_box_keypair(y, x) {
            randombytes(x, 32);
            return crypto_scalarmult_base(y, x);
          }
          function crypto_box_beforenm(k, y, x) {
            var s = new Uint8Array(32);
            crypto_scalarmult(s, x, y);
            return crypto_core_hsalsa20(k, _0, s, sigma);
          }
          var crypto_box_afternm = crypto_secretbox;
          var crypto_box_open_afternm = crypto_secretbox_open;
          function crypto_box(c, m, d, n, y, x) {
            var k = new Uint8Array(32);
            crypto_box_beforenm(k, y, x);
            return crypto_box_afternm(c, m, d, n, k);
          }
          function crypto_box_open(m, c, d, n, y, x) {
            var k = new Uint8Array(32);
            crypto_box_beforenm(k, y, x);
            return crypto_box_open_afternm(m, c, d, n, k);
          }
          var K = [
            1116352408, 3609767458, 1899447441, 602891725, 3049323471,
            3964484399, 3921009573, 2173295548, 961987163, 4081628472,
            1508970993, 3053834265, 2453635748, 2937671579, 2870763221,
            3664609560, 3624381080, 2734883394, 310598401, 1164996542,
            607225278, 1323610764, 1426881987, 3590304994, 1925078388,
            4068182383, 2162078206, 991336113, 2614888103, 633803317,
            3248222580, 3479774868, 3835390401, 2666613458, 4022224774,
            944711139, 264347078, 2341262773, 604807628, 2007800933, 770255983,
            1495990901, 1249150122, 1856431235, 1555081692, 3175218132,
            1996064986, 2198950837, 2554220882, 3999719339, 2821834349,
            766784016, 2952996808, 2566594879, 3210313671, 3203337956,
            3336571891, 1034457026, 3584528711, 2466948901, 113926993,
            3758326383, 338241895, 168717936, 666307205, 1188179964, 773529912,
            1546045734, 1294757372, 1522805485, 1396182291, 2643833823,
            1695183700, 2343527390, 1986661051, 1014477480, 2177026350,
            1206759142, 2456956037, 344077627, 2730485921, 1290863460,
            2820302411, 3158454273, 3259730800, 3505952657, 3345764771,
            106217008, 3516065817, 3606008344, 3600352804, 1432725776,
            4094571909, 1467031594, 275423344, 851169720, 430227734, 3100823752,
            506948616, 1363258195, 659060556, 3750685593, 883997877, 3785050280,
            958139571, 3318307427, 1322822218, 3812723403, 1537002063,
            2003034995, 1747873779, 3602036899, 1955562222, 1575990012,
            2024104815, 1125592928, 2227730452, 2716904306, 2361852424,
            442776044, 2428436474, 593698344, 2756734187, 3733110249,
            3204031479, 2999351573, 3329325298, 3815920427, 3391569614,
            3928383900, 3515267271, 566280711, 3940187606, 3454069534,
            4118630271, 4000239992, 116418474, 1914138554, 174292421,
            2731055270, 289380356, 3203993006, 460393269, 320620315, 685471733,
            587496836, 852142971, 1086792851, 1017036298, 365543100, 1126000580,
            2618297676, 1288033470, 3409855158, 1501505948, 4234509866,
            1607167915, 987167468, 1816402316, 1246189591,
          ];
          function crypto_hashblocks_hl(hh, hl, m, n) {
            var wh = new Int32Array(16),
              wl = new Int32Array(16),
              bh0,
              bh1,
              bh2,
              bh3,
              bh4,
              bh5,
              bh6,
              bh7,
              bl0,
              bl1,
              bl2,
              bl3,
              bl4,
              bl5,
              bl6,
              bl7,
              th,
              tl,
              i,
              j,
              h,
              l,
              a,
              b,
              c,
              d;
            var ah0 = hh[0],
              ah1 = hh[1],
              ah2 = hh[2],
              ah3 = hh[3],
              ah4 = hh[4],
              ah5 = hh[5],
              ah6 = hh[6],
              ah7 = hh[7],
              al0 = hl[0],
              al1 = hl[1],
              al2 = hl[2],
              al3 = hl[3],
              al4 = hl[4],
              al5 = hl[5],
              al6 = hl[6],
              al7 = hl[7];
            var pos = 0;
            while (n >= 128) {
              for (i = 0; i < 16; i++) {
                j = 8 * i + pos;
                wh[i] =
                  (m[j + 0] << 24) |
                  (m[j + 1] << 16) |
                  (m[j + 2] << 8) |
                  m[j + 3];
                wl[i] =
                  (m[j + 4] << 24) |
                  (m[j + 5] << 16) |
                  (m[j + 6] << 8) |
                  m[j + 7];
              }
              for (i = 0; i < 80; i++) {
                bh0 = ah0;
                bh1 = ah1;
                bh2 = ah2;
                bh3 = ah3;
                bh4 = ah4;
                bh5 = ah5;
                bh6 = ah6;
                bh7 = ah7;
                bl0 = al0;
                bl1 = al1;
                bl2 = al2;
                bl3 = al3;
                bl4 = al4;
                bl5 = al5;
                bl6 = al6;
                bl7 = al7;
                h = ah7;
                l = al7;
                a = l & 65535;
                b = l >>> 16;
                c = h & 65535;
                d = h >>> 16;
                h =
                  ((ah4 >>> 14) | (al4 << (32 - 14))) ^
                  ((ah4 >>> 18) | (al4 << (32 - 18))) ^
                  ((al4 >>> (41 - 32)) | (ah4 << (32 - (41 - 32))));
                l =
                  ((al4 >>> 14) | (ah4 << (32 - 14))) ^
                  ((al4 >>> 18) | (ah4 << (32 - 18))) ^
                  ((ah4 >>> (41 - 32)) | (al4 << (32 - (41 - 32))));
                a += l & 65535;
                b += l >>> 16;
                c += h & 65535;
                d += h >>> 16;
                h = (ah4 & ah5) ^ (~ah4 & ah6);
                l = (al4 & al5) ^ (~al4 & al6);
                a += l & 65535;
                b += l >>> 16;
                c += h & 65535;
                d += h >>> 16;
                h = K[i * 2];
                l = K[i * 2 + 1];
                a += l & 65535;
                b += l >>> 16;
                c += h & 65535;
                d += h >>> 16;
                h = wh[i % 16];
                l = wl[i % 16];
                a += l & 65535;
                b += l >>> 16;
                c += h & 65535;
                d += h >>> 16;
                b += a >>> 16;
                c += b >>> 16;
                d += c >>> 16;
                th = (c & 65535) | (d << 16);
                tl = (a & 65535) | (b << 16);
                h = th;
                l = tl;
                a = l & 65535;
                b = l >>> 16;
                c = h & 65535;
                d = h >>> 16;
                h =
                  ((ah0 >>> 28) | (al0 << (32 - 28))) ^
                  ((al0 >>> (34 - 32)) | (ah0 << (32 - (34 - 32)))) ^
                  ((al0 >>> (39 - 32)) | (ah0 << (32 - (39 - 32))));
                l =
                  ((al0 >>> 28) | (ah0 << (32 - 28))) ^
                  ((ah0 >>> (34 - 32)) | (al0 << (32 - (34 - 32)))) ^
                  ((ah0 >>> (39 - 32)) | (al0 << (32 - (39 - 32))));
                a += l & 65535;
                b += l >>> 16;
                c += h & 65535;
                d += h >>> 16;
                h = (ah0 & ah1) ^ (ah0 & ah2) ^ (ah1 & ah2);
                l = (al0 & al1) ^ (al0 & al2) ^ (al1 & al2);
                a += l & 65535;
                b += l >>> 16;
                c += h & 65535;
                d += h >>> 16;
                b += a >>> 16;
                c += b >>> 16;
                d += c >>> 16;
                bh7 = (c & 65535) | (d << 16);
                bl7 = (a & 65535) | (b << 16);
                h = bh3;
                l = bl3;
                a = l & 65535;
                b = l >>> 16;
                c = h & 65535;
                d = h >>> 16;
                h = th;
                l = tl;
                a += l & 65535;
                b += l >>> 16;
                c += h & 65535;
                d += h >>> 16;
                b += a >>> 16;
                c += b >>> 16;
                d += c >>> 16;
                bh3 = (c & 65535) | (d << 16);
                bl3 = (a & 65535) | (b << 16);
                ah1 = bh0;
                ah2 = bh1;
                ah3 = bh2;
                ah4 = bh3;
                ah5 = bh4;
                ah6 = bh5;
                ah7 = bh6;
                ah0 = bh7;
                al1 = bl0;
                al2 = bl1;
                al3 = bl2;
                al4 = bl3;
                al5 = bl4;
                al6 = bl5;
                al7 = bl6;
                al0 = bl7;
                if (i % 16 === 15) {
                  for (j = 0; j < 16; j++) {
                    h = wh[j];
                    l = wl[j];
                    a = l & 65535;
                    b = l >>> 16;
                    c = h & 65535;
                    d = h >>> 16;
                    h = wh[(j + 9) % 16];
                    l = wl[(j + 9) % 16];
                    a += l & 65535;
                    b += l >>> 16;
                    c += h & 65535;
                    d += h >>> 16;
                    th = wh[(j + 1) % 16];
                    tl = wl[(j + 1) % 16];
                    h =
                      ((th >>> 1) | (tl << (32 - 1))) ^
                      ((th >>> 8) | (tl << (32 - 8))) ^
                      (th >>> 7);
                    l =
                      ((tl >>> 1) | (th << (32 - 1))) ^
                      ((tl >>> 8) | (th << (32 - 8))) ^
                      ((tl >>> 7) | (th << (32 - 7)));
                    a += l & 65535;
                    b += l >>> 16;
                    c += h & 65535;
                    d += h >>> 16;
                    th = wh[(j + 14) % 16];
                    tl = wl[(j + 14) % 16];
                    h =
                      ((th >>> 19) | (tl << (32 - 19))) ^
                      ((tl >>> (61 - 32)) | (th << (32 - (61 - 32)))) ^
                      (th >>> 6);
                    l =
                      ((tl >>> 19) | (th << (32 - 19))) ^
                      ((th >>> (61 - 32)) | (tl << (32 - (61 - 32)))) ^
                      ((tl >>> 6) | (th << (32 - 6)));
                    a += l & 65535;
                    b += l >>> 16;
                    c += h & 65535;
                    d += h >>> 16;
                    b += a >>> 16;
                    c += b >>> 16;
                    d += c >>> 16;
                    wh[j] = (c & 65535) | (d << 16);
                    wl[j] = (a & 65535) | (b << 16);
                  }
                }
              }
              h = ah0;
              l = al0;
              a = l & 65535;
              b = l >>> 16;
              c = h & 65535;
              d = h >>> 16;
              h = hh[0];
              l = hl[0];
              a += l & 65535;
              b += l >>> 16;
              c += h & 65535;
              d += h >>> 16;
              b += a >>> 16;
              c += b >>> 16;
              d += c >>> 16;
              hh[0] = ah0 = (c & 65535) | (d << 16);
              hl[0] = al0 = (a & 65535) | (b << 16);
              h = ah1;
              l = al1;
              a = l & 65535;
              b = l >>> 16;
              c = h & 65535;
              d = h >>> 16;
              h = hh[1];
              l = hl[1];
              a += l & 65535;
              b += l >>> 16;
              c += h & 65535;
              d += h >>> 16;
              b += a >>> 16;
              c += b >>> 16;
              d += c >>> 16;
              hh[1] = ah1 = (c & 65535) | (d << 16);
              hl[1] = al1 = (a & 65535) | (b << 16);
              h = ah2;
              l = al2;
              a = l & 65535;
              b = l >>> 16;
              c = h & 65535;
              d = h >>> 16;
              h = hh[2];
              l = hl[2];
              a += l & 65535;
              b += l >>> 16;
              c += h & 65535;
              d += h >>> 16;
              b += a >>> 16;
              c += b >>> 16;
              d += c >>> 16;
              hh[2] = ah2 = (c & 65535) | (d << 16);
              hl[2] = al2 = (a & 65535) | (b << 16);
              h = ah3;
              l = al3;
              a = l & 65535;
              b = l >>> 16;
              c = h & 65535;
              d = h >>> 16;
              h = hh[3];
              l = hl[3];
              a += l & 65535;
              b += l >>> 16;
              c += h & 65535;
              d += h >>> 16;
              b += a >>> 16;
              c += b >>> 16;
              d += c >>> 16;
              hh[3] = ah3 = (c & 65535) | (d << 16);
              hl[3] = al3 = (a & 65535) | (b << 16);
              h = ah4;
              l = al4;
              a = l & 65535;
              b = l >>> 16;
              c = h & 65535;
              d = h >>> 16;
              h = hh[4];
              l = hl[4];
              a += l & 65535;
              b += l >>> 16;
              c += h & 65535;
              d += h >>> 16;
              b += a >>> 16;
              c += b >>> 16;
              d += c >>> 16;
              hh[4] = ah4 = (c & 65535) | (d << 16);
              hl[4] = al4 = (a & 65535) | (b << 16);
              h = ah5;
              l = al5;
              a = l & 65535;
              b = l >>> 16;
              c = h & 65535;
              d = h >>> 16;
              h = hh[5];
              l = hl[5];
              a += l & 65535;
              b += l >>> 16;
              c += h & 65535;
              d += h >>> 16;
              b += a >>> 16;
              c += b >>> 16;
              d += c >>> 16;
              hh[5] = ah5 = (c & 65535) | (d << 16);
              hl[5] = al5 = (a & 65535) | (b << 16);
              h = ah6;
              l = al6;
              a = l & 65535;
              b = l >>> 16;
              c = h & 65535;
              d = h >>> 16;
              h = hh[6];
              l = hl[6];
              a += l & 65535;
              b += l >>> 16;
              c += h & 65535;
              d += h >>> 16;
              b += a >>> 16;
              c += b >>> 16;
              d += c >>> 16;
              hh[6] = ah6 = (c & 65535) | (d << 16);
              hl[6] = al6 = (a & 65535) | (b << 16);
              h = ah7;
              l = al7;
              a = l & 65535;
              b = l >>> 16;
              c = h & 65535;
              d = h >>> 16;
              h = hh[7];
              l = hl[7];
              a += l & 65535;
              b += l >>> 16;
              c += h & 65535;
              d += h >>> 16;
              b += a >>> 16;
              c += b >>> 16;
              d += c >>> 16;
              hh[7] = ah7 = (c & 65535) | (d << 16);
              hl[7] = al7 = (a & 65535) | (b << 16);
              pos += 128;
              n -= 128;
            }
            return n;
          }
          function crypto_hash(out, m, n) {
            var hh = new Int32Array(8),
              hl = new Int32Array(8),
              x = new Uint8Array(256),
              i,
              b = n;
            hh[0] = 1779033703;
            hh[1] = 3144134277;
            hh[2] = 1013904242;
            hh[3] = 2773480762;
            hh[4] = 1359893119;
            hh[5] = 2600822924;
            hh[6] = 528734635;
            hh[7] = 1541459225;
            hl[0] = 4089235720;
            hl[1] = 2227873595;
            hl[2] = 4271175723;
            hl[3] = 1595750129;
            hl[4] = 2917565137;
            hl[5] = 725511199;
            hl[6] = 4215389547;
            hl[7] = 327033209;
            crypto_hashblocks_hl(hh, hl, m, n);
            n %= 128;
            for (i = 0; i < n; i++) x[i] = m[b - n + i];
            x[n] = 128;
            n = 256 - 128 * (n < 112 ? 1 : 0);
            x[n - 9] = 0;
            ts64(x, n - 8, (b / 536870912) | 0, b << 3);
            crypto_hashblocks_hl(hh, hl, x, n);
            for (i = 0; i < 8; i++) ts64(out, 8 * i, hh[i], hl[i]);
            return 0;
          }
          function add(p, q) {
            var a = gf(),
              b = gf(),
              c = gf(),
              d = gf(),
              e = gf(),
              f = gf(),
              g = gf(),
              h = gf(),
              t = gf();
            Z(a, p[1], p[0]);
            Z(t, q[1], q[0]);
            M(a, a, t);
            A(b, p[0], p[1]);
            A(t, q[0], q[1]);
            M(b, b, t);
            M(c, p[3], q[3]);
            M(c, c, D2);
            M(d, p[2], q[2]);
            A(d, d, d);
            Z(e, b, a);
            Z(f, d, c);
            A(g, d, c);
            A(h, b, a);
            M(p[0], e, f);
            M(p[1], h, g);
            M(p[2], g, f);
            M(p[3], e, h);
          }
          function cswap(p, q, b) {
            var i;
            for (i = 0; i < 4; i++) {
              sel25519(p[i], q[i], b);
            }
          }
          function pack(r, p) {
            var tx = gf(),
              ty = gf(),
              zi = gf();
            inv25519(zi, p[2]);
            M(tx, p[0], zi);
            M(ty, p[1], zi);
            pack25519(r, ty);
            r[31] ^= par25519(tx) << 7;
          }
          function scalarmult(p, q, s) {
            var b, i;
            set25519(p[0], gf0);
            set25519(p[1], gf1);
            set25519(p[2], gf1);
            set25519(p[3], gf0);
            for (i = 255; i >= 0; --i) {
              b = (s[(i / 8) | 0] >> (i & 7)) & 1;
              cswap(p, q, b);
              add(q, p);
              add(p, p);
              cswap(p, q, b);
            }
          }
          function scalarbase(p, s) {
            var q = [gf(), gf(), gf(), gf()];
            set25519(q[0], X);
            set25519(q[1], Y);
            set25519(q[2], gf1);
            M(q[3], X, Y);
            scalarmult(p, q, s);
          }
          function crypto_sign_keypair(pk, sk, seeded) {
            var d = new Uint8Array(64);
            var p = [gf(), gf(), gf(), gf()];
            var i;
            if (!seeded) randombytes(sk, 32);
            crypto_hash(d, sk, 32);
            d[0] &= 248;
            d[31] &= 127;
            d[31] |= 64;
            scalarbase(p, d);
            pack(pk, p);
            for (i = 0; i < 32; i++) sk[i + 32] = pk[i];
            return 0;
          }
          var L = new Float64Array([
            237, 211, 245, 92, 26, 99, 18, 88, 214, 156, 247, 162, 222, 249,
            222, 20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16,
          ]);
          function modL(r, x) {
            var carry, i, j, k;
            for (i = 63; i >= 32; --i) {
              carry = 0;
              for (j = i - 32, k = i - 12; j < k; ++j) {
                x[j] += carry - 16 * x[i] * L[j - (i - 32)];
                carry = Math.floor((x[j] + 128) / 256);
                x[j] -= carry * 256;
              }
              x[j] += carry;
              x[i] = 0;
            }
            carry = 0;
            for (j = 0; j < 32; j++) {
              x[j] += carry - (x[31] >> 4) * L[j];
              carry = x[j] >> 8;
              x[j] &= 255;
            }
            for (j = 0; j < 32; j++) x[j] -= carry * L[j];
            for (i = 0; i < 32; i++) {
              x[i + 1] += x[i] >> 8;
              r[i] = x[i] & 255;
            }
          }
          function reduce(r) {
            var x = new Float64Array(64),
              i;
            for (i = 0; i < 64; i++) x[i] = r[i];
            for (i = 0; i < 64; i++) r[i] = 0;
            modL(r, x);
          }
          function crypto_sign(sm, m, n, sk) {
            var d = new Uint8Array(64),
              h = new Uint8Array(64),
              r = new Uint8Array(64);
            var i,
              j,
              x = new Float64Array(64);
            var p = [gf(), gf(), gf(), gf()];
            crypto_hash(d, sk, 32);
            d[0] &= 248;
            d[31] &= 127;
            d[31] |= 64;
            var smlen = n + 64;
            for (i = 0; i < n; i++) sm[64 + i] = m[i];
            for (i = 0; i < 32; i++) sm[32 + i] = d[32 + i];
            crypto_hash(r, sm.subarray(32), n + 32);
            reduce(r);
            scalarbase(p, r);
            pack(sm, p);
            for (i = 32; i < 64; i++) sm[i] = sk[i];
            crypto_hash(h, sm, n + 64);
            reduce(h);
            for (i = 0; i < 64; i++) x[i] = 0;
            for (i = 0; i < 32; i++) x[i] = r[i];
            for (i = 0; i < 32; i++) {
              for (j = 0; j < 32; j++) {
                x[i + j] += h[i] * d[j];
              }
            }
            modL(sm.subarray(32), x);
            return smlen;
          }
          function unpackneg(r, p) {
            var t = gf(),
              chk = gf(),
              num = gf(),
              den = gf(),
              den2 = gf(),
              den4 = gf(),
              den6 = gf();
            set25519(r[2], gf1);
            unpack25519(r[1], p);
            S(num, r[1]);
            M(den, num, D);
            Z(num, num, r[2]);
            A(den, r[2], den);
            S(den2, den);
            S(den4, den2);
            M(den6, den4, den2);
            M(t, den6, num);
            M(t, t, den);
            pow2523(t, t);
            M(t, t, num);
            M(t, t, den);
            M(t, t, den);
            M(r[0], t, den);
            S(chk, r[0]);
            M(chk, chk, den);
            if (neq25519(chk, num)) M(r[0], r[0], I);
            S(chk, r[0]);
            M(chk, chk, den);
            if (neq25519(chk, num)) return -1;
            if (par25519(r[0]) === p[31] >> 7) Z(r[0], gf0, r[0]);
            M(r[3], r[0], r[1]);
            return 0;
          }
          function crypto_sign_open(m, sm, n, pk) {
            var i;
            var t = new Uint8Array(32),
              h = new Uint8Array(64);
            var p = [gf(), gf(), gf(), gf()],
              q = [gf(), gf(), gf(), gf()];
            if (n < 64) return -1;
            if (unpackneg(q, pk)) return -1;
            for (i = 0; i < n; i++) m[i] = sm[i];
            for (i = 0; i < 32; i++) m[i + 32] = pk[i];
            crypto_hash(h, m, n);
            reduce(h);
            scalarmult(p, q, h);
            scalarbase(q, sm.subarray(32));
            add(p, q);
            pack(t, p);
            n -= 64;
            if (crypto_verify_32(sm, 0, t, 0)) {
              for (i = 0; i < n; i++) m[i] = 0;
              return -1;
            }
            for (i = 0; i < n; i++) m[i] = sm[i + 64];
            return n;
          }
          var crypto_secretbox_KEYBYTES = 32,
            crypto_secretbox_NONCEBYTES = 24,
            crypto_secretbox_ZEROBYTES = 32,
            crypto_secretbox_BOXZEROBYTES = 16,
            crypto_scalarmult_BYTES = 32,
            crypto_scalarmult_SCALARBYTES = 32,
            crypto_box_PUBLICKEYBYTES = 32,
            crypto_box_SECRETKEYBYTES = 32,
            crypto_box_BEFORENMBYTES = 32,
            crypto_box_NONCEBYTES = crypto_secretbox_NONCEBYTES,
            crypto_box_ZEROBYTES = crypto_secretbox_ZEROBYTES,
            crypto_box_BOXZEROBYTES = crypto_secretbox_BOXZEROBYTES,
            crypto_sign_BYTES = 64,
            crypto_sign_PUBLICKEYBYTES = 32,
            crypto_sign_SECRETKEYBYTES = 64,
            crypto_sign_SEEDBYTES = 32,
            crypto_hash_BYTES = 64;
          nacl.lowlevel = {
            crypto_core_hsalsa20: crypto_core_hsalsa20,
            crypto_stream_xor: crypto_stream_xor,
            crypto_stream: crypto_stream,
            crypto_stream_salsa20_xor: crypto_stream_salsa20_xor,
            crypto_stream_salsa20: crypto_stream_salsa20,
            crypto_onetimeauth: crypto_onetimeauth,
            crypto_onetimeauth_verify: crypto_onetimeauth_verify,
            crypto_verify_16: crypto_verify_16,
            crypto_verify_32: crypto_verify_32,
            crypto_secretbox: crypto_secretbox,
            crypto_secretbox_open: crypto_secretbox_open,
            crypto_scalarmult: crypto_scalarmult,
            crypto_scalarmult_base: crypto_scalarmult_base,
            crypto_box_beforenm: crypto_box_beforenm,
            crypto_box_afternm: crypto_box_afternm,
            crypto_box: crypto_box,
            crypto_box_open: crypto_box_open,
            crypto_box_keypair: crypto_box_keypair,
            crypto_hash: crypto_hash,
            crypto_sign: crypto_sign,
            crypto_sign_keypair: crypto_sign_keypair,
            crypto_sign_open: crypto_sign_open,
            crypto_secretbox_KEYBYTES: crypto_secretbox_KEYBYTES,
            crypto_secretbox_NONCEBYTES: crypto_secretbox_NONCEBYTES,
            crypto_secretbox_ZEROBYTES: crypto_secretbox_ZEROBYTES,
            crypto_secretbox_BOXZEROBYTES: crypto_secretbox_BOXZEROBYTES,
            crypto_scalarmult_BYTES: crypto_scalarmult_BYTES,
            crypto_scalarmult_SCALARBYTES: crypto_scalarmult_SCALARBYTES,
            crypto_box_PUBLICKEYBYTES: crypto_box_PUBLICKEYBYTES,
            crypto_box_SECRETKEYBYTES: crypto_box_SECRETKEYBYTES,
            crypto_box_BEFORENMBYTES: crypto_box_BEFORENMBYTES,
            crypto_box_NONCEBYTES: crypto_box_NONCEBYTES,
            crypto_box_ZEROBYTES: crypto_box_ZEROBYTES,
            crypto_box_BOXZEROBYTES: crypto_box_BOXZEROBYTES,
            crypto_sign_BYTES: crypto_sign_BYTES,
            crypto_sign_PUBLICKEYBYTES: crypto_sign_PUBLICKEYBYTES,
            crypto_sign_SECRETKEYBYTES: crypto_sign_SECRETKEYBYTES,
            crypto_sign_SEEDBYTES: crypto_sign_SEEDBYTES,
            crypto_hash_BYTES: crypto_hash_BYTES,
            gf: gf,
            D: D,
            L: L,
            pack25519: pack25519,
            unpack25519: unpack25519,
            M: M,
            A: A,
            S: S,
            Z: Z,
            pow2523: pow2523,
            add: add,
            set25519: set25519,
            modL: modL,
            scalarmult: scalarmult,
            scalarbase: scalarbase,
          };
          function checkLengths(k, n) {
            if (k.length !== crypto_secretbox_KEYBYTES)
              throw new Error("bad key size");
            if (n.length !== crypto_secretbox_NONCEBYTES)
              throw new Error("bad nonce size");
          }
          function checkBoxLengths(pk, sk) {
            if (pk.length !== crypto_box_PUBLICKEYBYTES)
              throw new Error("bad public key size");
            if (sk.length !== crypto_box_SECRETKEYBYTES)
              throw new Error("bad secret key size");
          }
          function checkArrayTypes() {
            for (var i = 0; i < arguments.length; i++) {
              if (!(arguments[i] instanceof Uint8Array))
                throw new TypeError("unexpected type, use Uint8Array");
            }
          }
          function cleanup(arr) {
            for (var i = 0; i < arr.length; i++) arr[i] = 0;
          }
          nacl.randomBytes = function (n) {
            var b = new Uint8Array(n);
            randombytes(b, n);
            return b;
          };
          nacl.secretbox = function (msg, nonce, key) {
            checkArrayTypes(msg, nonce, key);
            checkLengths(key, nonce);
            var m = new Uint8Array(crypto_secretbox_ZEROBYTES + msg.length);
            var c = new Uint8Array(m.length);
            for (var i = 0; i < msg.length; i++)
              m[i + crypto_secretbox_ZEROBYTES] = msg[i];
            crypto_secretbox(c, m, m.length, nonce, key);
            return c.subarray(crypto_secretbox_BOXZEROBYTES);
          };
          nacl.secretbox.open = function (box, nonce, key) {
            checkArrayTypes(box, nonce, key);
            checkLengths(key, nonce);
            var c = new Uint8Array(crypto_secretbox_BOXZEROBYTES + box.length);
            var m = new Uint8Array(c.length);
            for (var i = 0; i < box.length; i++)
              c[i + crypto_secretbox_BOXZEROBYTES] = box[i];
            if (c.length < 32) return null;
            if (crypto_secretbox_open(m, c, c.length, nonce, key) !== 0)
              return null;
            return m.subarray(crypto_secretbox_ZEROBYTES);
          };
          nacl.secretbox.keyLength = crypto_secretbox_KEYBYTES;
          nacl.secretbox.nonceLength = crypto_secretbox_NONCEBYTES;
          nacl.secretbox.overheadLength = crypto_secretbox_BOXZEROBYTES;
          nacl.scalarMult = function (n, p) {
            checkArrayTypes(n, p);
            if (n.length !== crypto_scalarmult_SCALARBYTES)
              throw new Error("bad n size");
            if (p.length !== crypto_scalarmult_BYTES)
              throw new Error("bad p size");
            var q = new Uint8Array(crypto_scalarmult_BYTES);
            crypto_scalarmult(q, n, p);
            return q;
          };
          nacl.scalarMult.base = function (n) {
            checkArrayTypes(n);
            if (n.length !== crypto_scalarmult_SCALARBYTES)
              throw new Error("bad n size");
            var q = new Uint8Array(crypto_scalarmult_BYTES);
            crypto_scalarmult_base(q, n);
            return q;
          };
          nacl.scalarMult.scalarLength = crypto_scalarmult_SCALARBYTES;
          nacl.scalarMult.groupElementLength = crypto_scalarmult_BYTES;
          nacl.box = function (msg, nonce, publicKey, secretKey) {
            var k = nacl.box.before(publicKey, secretKey);
            return nacl.secretbox(msg, nonce, k);
          };
          nacl.box.before = function (publicKey, secretKey) {
            checkArrayTypes(publicKey, secretKey);
            checkBoxLengths(publicKey, secretKey);
            var k = new Uint8Array(crypto_box_BEFORENMBYTES);
            crypto_box_beforenm(k, publicKey, secretKey);
            return k;
          };
          nacl.box.after = nacl.secretbox;
          nacl.box.open = function (msg, nonce, publicKey, secretKey) {
            var k = nacl.box.before(publicKey, secretKey);
            return nacl.secretbox.open(msg, nonce, k);
          };
          nacl.box.open.after = nacl.secretbox.open;
          nacl.box.keyPair = function () {
            var pk = new Uint8Array(crypto_box_PUBLICKEYBYTES);
            var sk = new Uint8Array(crypto_box_SECRETKEYBYTES);
            crypto_box_keypair(pk, sk);
            return { publicKey: pk, secretKey: sk };
          };
          nacl.box.keyPair.fromSecretKey = function (secretKey) {
            checkArrayTypes(secretKey);
            if (secretKey.length !== crypto_box_SECRETKEYBYTES)
              throw new Error("bad secret key size");
            var pk = new Uint8Array(crypto_box_PUBLICKEYBYTES);
            crypto_scalarmult_base(pk, secretKey);
            return { publicKey: pk, secretKey: new Uint8Array(secretKey) };
          };
          nacl.box.publicKeyLength = crypto_box_PUBLICKEYBYTES;
          nacl.box.secretKeyLength = crypto_box_SECRETKEYBYTES;
          nacl.box.sharedKeyLength = crypto_box_BEFORENMBYTES;
          nacl.box.nonceLength = crypto_box_NONCEBYTES;
          nacl.box.overheadLength = nacl.secretbox.overheadLength;
          nacl.sign = function (msg, secretKey) {
            checkArrayTypes(msg, secretKey);
            if (secretKey.length !== crypto_sign_SECRETKEYBYTES)
              throw new Error("bad secret key size");
            var signedMsg = new Uint8Array(crypto_sign_BYTES + msg.length);
            crypto_sign(signedMsg, msg, msg.length, secretKey);
            return signedMsg;
          };
          nacl.sign.open = function (signedMsg, publicKey) {
            checkArrayTypes(signedMsg, publicKey);
            if (publicKey.length !== crypto_sign_PUBLICKEYBYTES)
              throw new Error("bad public key size");
            var tmp = new Uint8Array(signedMsg.length);
            var mlen = crypto_sign_open(
              tmp,
              signedMsg,
              signedMsg.length,
              publicKey
            );
            if (mlen < 0) return null;
            var m = new Uint8Array(mlen);
            for (var i = 0; i < m.length; i++) m[i] = tmp[i];
            return m;
          };
          nacl.sign.detached = function (msg, secretKey) {
            var signedMsg = nacl.sign(msg, secretKey);
            var sig = new Uint8Array(crypto_sign_BYTES);
            for (var i = 0; i < sig.length; i++) sig[i] = signedMsg[i];
            return sig;
          };
          nacl.sign.detached.verify = function (msg, sig, publicKey) {
            checkArrayTypes(msg, sig, publicKey);
            if (sig.length !== crypto_sign_BYTES)
              throw new Error("bad signature size");
            if (publicKey.length !== crypto_sign_PUBLICKEYBYTES)
              throw new Error("bad public key size");
            var sm = new Uint8Array(crypto_sign_BYTES + msg.length);
            var m = new Uint8Array(crypto_sign_BYTES + msg.length);
            var i;
            for (i = 0; i < crypto_sign_BYTES; i++) sm[i] = sig[i];
            for (i = 0; i < msg.length; i++) sm[i + crypto_sign_BYTES] = msg[i];
            return crypto_sign_open(m, sm, sm.length, publicKey) >= 0;
          };
          nacl.sign.keyPair = function () {
            var pk = new Uint8Array(crypto_sign_PUBLICKEYBYTES);
            var sk = new Uint8Array(crypto_sign_SECRETKEYBYTES);
            crypto_sign_keypair(pk, sk);
            return { publicKey: pk, secretKey: sk };
          };
          nacl.sign.keyPair.fromSecretKey = function (secretKey) {
            checkArrayTypes(secretKey);
            if (secretKey.length !== crypto_sign_SECRETKEYBYTES)
              throw new Error("bad secret key size");
            var pk = new Uint8Array(crypto_sign_PUBLICKEYBYTES);
            for (var i = 0; i < pk.length; i++) pk[i] = secretKey[32 + i];
            return { publicKey: pk, secretKey: new Uint8Array(secretKey) };
          };
          nacl.sign.keyPair.fromSeed = function (seed) {
            checkArrayTypes(seed);
            if (seed.length !== crypto_sign_SEEDBYTES)
              throw new Error("bad seed size");
            var pk = new Uint8Array(crypto_sign_PUBLICKEYBYTES);
            var sk = new Uint8Array(crypto_sign_SECRETKEYBYTES);
            for (var i = 0; i < 32; i++) sk[i] = seed[i];
            crypto_sign_keypair(pk, sk, true);
            return { publicKey: pk, secretKey: sk };
          };
          nacl.sign.publicKeyLength = crypto_sign_PUBLICKEYBYTES;
          nacl.sign.secretKeyLength = crypto_sign_SECRETKEYBYTES;
          nacl.sign.seedLength = crypto_sign_SEEDBYTES;
          nacl.sign.signatureLength = crypto_sign_BYTES;
          nacl.hash = function (msg) {
            checkArrayTypes(msg);
            var h = new Uint8Array(crypto_hash_BYTES);
            crypto_hash(h, msg, msg.length);
            return h;
          };
          nacl.hash.hashLength = crypto_hash_BYTES;
          nacl.verify = function (x, y) {
            checkArrayTypes(x, y);
            if (x.length === 0 || y.length === 0) return false;
            if (x.length !== y.length) return false;
            return vn(x, 0, y, 0, x.length) === 0 ? true : false;
          };
          nacl.setPRNG = function (fn) {
            randombytes = fn;
          };
          (function () {
            var crypto =
              typeof self !== "undefined" ? self.crypto || self.msCrypto : null;
            if (crypto && crypto.getRandomValues) {
              var QUOTA = 65536;
              nacl.setPRNG(function (x, n) {
                var i,
                  v = new Uint8Array(n);
                for (i = 0; i < n; i += QUOTA) {
                  crypto.getRandomValues(
                    v.subarray(i, i + Math.min(n - i, QUOTA))
                  );
                }
                for (i = 0; i < n; i++) x[i] = v[i];
                cleanup(v);
              });
            } else if (typeof require !== "undefined") {
              crypto = require("crypto");
              if (crypto && crypto.randomBytes) {
                nacl.setPRNG(function (x, n) {
                  var i,
                    v = crypto.randomBytes(n);
                  for (i = 0; i < n; i++) x[i] = v[i];
                  cleanup(v);
                });
              }
            }
          })();
        })(
          typeof module !== "undefined" && module.exports
            ? module.exports
            : (self.nacl = self.nacl || {})
        );
      },
      { crypto: 24 },
    ],
    157: [
      function (require, module, exports) {
        (function (global) {
          (function () {
            module.exports = deprecate;
            function deprecate(fn, msg) {
              if (config("noDeprecation")) {
                return fn;
              }
              var warned = false;
              function deprecated() {
                if (!warned) {
                  if (config("throwDeprecation")) {
                    throw new Error(msg);
                  } else if (config("traceDeprecation")) {
                    console.trace(msg);
                  } else {
                    console.warn(msg);
                  }
                  warned = true;
                }
                return fn.apply(this, arguments);
              }
              return deprecated;
            }
            function config(name) {
              try {
                if (!global.localStorage) return false;
              } catch (_) {
                return false;
              }
              var val = global.localStorage[name];
              if (null == val) return false;
              return String(val).toLowerCase() === "true";
            }
          }).call(this);
        }).call(
          this,
          typeof global !== "undefined"
            ? global
            : typeof self !== "undefined"
            ? self
            : typeof window !== "undefined"
            ? window
            : {}
        );
      },
      {},
    ],
    158: [
      function (require, module, exports) {
        "use strict";
        function _typeof(obj) {
          "@babel/helpers - typeof";
          return (
            (_typeof =
              "function" == typeof Symbol && "symbol" == typeof Symbol.iterator
                ? function (obj) {
                    return typeof obj;
                  }
                : function (obj) {
                    return obj &&
                      "function" == typeof Symbol &&
                      obj.constructor === Symbol &&
                      obj !== Symbol.prototype
                      ? "symbol"
                      : typeof obj;
                  }),
            _typeof(obj)
          );
        }
        var _events = require("events");
        function _classCallCheck(instance, Constructor) {
          if (!(instance instanceof Constructor)) {
            throw new TypeError("Cannot call a class as a function");
          }
        }
        function _defineProperties(target, props) {
          for (var i = 0; i < props.length; i++) {
            var descriptor = props[i];
            descriptor.enumerable = descriptor.enumerable || false;
            descriptor.configurable = true;
            if ("value" in descriptor) descriptor.writable = true;
            Object.defineProperty(target, descriptor.key, descriptor);
          }
        }
        function _createClass(Constructor, protoProps, staticProps) {
          if (protoProps) _defineProperties(Constructor.prototype, protoProps);
          if (staticProps) _defineProperties(Constructor, staticProps);
          Object.defineProperty(Constructor, "prototype", { writable: false });
          return Constructor;
        }
        function _inherits(subClass, superClass) {
          if (typeof superClass !== "function" && superClass !== null) {
            throw new TypeError(
              "Super expression must either be null or a function"
            );
          }
          subClass.prototype = Object.create(
            superClass && superClass.prototype,
            {
              constructor: {
                value: subClass,
                writable: true,
                configurable: true,
              },
            }
          );
          Object.defineProperty(subClass, "prototype", { writable: false });
          if (superClass) _setPrototypeOf(subClass, superClass);
        }
        function _setPrototypeOf(o, p) {
          _setPrototypeOf =
            Object.setPrototypeOf ||
            function _setPrototypeOf(o, p) {
              o.__proto__ = p;
              return o;
            };
          return _setPrototypeOf(o, p);
        }
        function _createSuper(Derived) {
          var hasNativeReflectConstruct = _isNativeReflectConstruct();
          return function _createSuperInternal() {
            var Super = _getPrototypeOf(Derived),
              result;
            if (hasNativeReflectConstruct) {
              var NewTarget = _getPrototypeOf(this).constructor;
              result = Reflect.construct(Super, arguments, NewTarget);
            } else {
              result = Super.apply(this, arguments);
            }
            return _possibleConstructorReturn(this, result);
          };
        }
        function _possibleConstructorReturn(self, call) {
          if (
            call &&
            (_typeof(call) === "object" || typeof call === "function")
          ) {
            return call;
          } else if (call !== void 0) {
            throw new TypeError(
              "Derived constructors may only return object or undefined"
            );
          }
          return _assertThisInitialized(self);
        }
        function _assertThisInitialized(self) {
          if (self === void 0) {
            throw new ReferenceError(
              "this hasn't been initialised - super() hasn't been called"
            );
          }
          return self;
        }
        function _isNativeReflectConstruct() {
          if (typeof Reflect === "undefined" || !Reflect.construct)
            return false;
          if (Reflect.construct.sham) return false;
          if (typeof Proxy === "function") return true;
          try {
            Boolean.prototype.valueOf.call(
              Reflect.construct(Boolean, [], function () {})
            );
            return true;
          } catch (e) {
            return false;
          }
        }
        function _getPrototypeOf(o) {
          _getPrototypeOf = Object.setPrototypeOf
            ? Object.getPrototypeOf
            : function _getPrototypeOf(o) {
                return o.__proto__ || Object.getPrototypeOf(o);
              };
          return _getPrototypeOf(o);
        }
        var BaseProvider = (function (_EventEmitter) {
          _inherits(BaseProvider, _EventEmitter);
          var _super = _createSuper(BaseProvider);
          function BaseProvider(config) {
            var _this;
            _classCallCheck(this, BaseProvider);
            _this = _super.call(this);
            _this.isDebug = !!config.isDebug;
            _this.isPosi = true;
            return _this;
          }
          _createClass(BaseProvider, [
            {
              key: "postMessage",
              value: function postMessage(handler, id, data) {
                var object = {
                  id: id,
                  name: handler,
                  object: data,
                  network: this.providerNetwork,
                };
                if (window.posiwallet.postMessage) {
                  window.posiwallet.postMessage(object);
                } else {
                  console.error("postMessage is not available");
                }
              },
            },
            {
              key: "sendResponse",
              value: function sendResponse(id, result) {
                var callback = this.callbacks.get(id);
                if (this.isDebug) {
                  console.log(
                    "<== sendResponse id: "
                      .concat(id, ", result: ")
                      .concat(JSON.stringify(result))
                  );
                }
                if (callback) {
                  callback(null, result);
                  this.callbacks["delete"](id);
                } else {
                  console.log("callback id: ".concat(id, " not found"));
                }
              },
            },
            {
              key: "sendError",
              value: function sendError(id, error) {
                console.log("<== ".concat(id, " sendError ").concat(error));
                var callback = this.callbacks.get(id);
                if (callback) {
                  callback(
                    error instanceof Error ? error : new Error(error),
                    null
                  );
                  this.callbacks["delete"](id);
                }
              },
            },
          ]);
          return BaseProvider;
        })(_events.EventEmitter);
        module.exports = BaseProvider;
      },
      { events: 63 },
    ],
    159: [
      function (require, module, exports) {
        "use strict";
        function _typeof(obj) {
          "@babel/helpers - typeof";
          return (
            (_typeof =
              "function" == typeof Symbol && "symbol" == typeof Symbol.iterator
                ? function (obj) {
                    return typeof obj;
                  }
                : function (obj) {
                    return obj &&
                      "function" == typeof Symbol &&
                      obj.constructor === Symbol &&
                      obj !== Symbol.prototype
                      ? "symbol"
                      : typeof obj;
                  }),
            _typeof(obj)
          );
        }
        function _classCallCheck(instance, Constructor) {
          if (!(instance instanceof Constructor)) {
            throw new TypeError("Cannot call a class as a function");
          }
        }
        function _defineProperties(target, props) {
          for (var i = 0; i < props.length; i++) {
            var descriptor = props[i];
            descriptor.enumerable = descriptor.enumerable || false;
            descriptor.configurable = true;
            if ("value" in descriptor) descriptor.writable = true;
            Object.defineProperty(target, descriptor.key, descriptor);
          }
        }
        function _createClass(Constructor, protoProps, staticProps) {
          if (protoProps) _defineProperties(Constructor.prototype, protoProps);
          if (staticProps) _defineProperties(Constructor, staticProps);
          Object.defineProperty(Constructor, "prototype", { writable: false });
          return Constructor;
        }
        function _inherits(subClass, superClass) {
          if (typeof superClass !== "function" && superClass !== null) {
            throw new TypeError(
              "Super expression must either be null or a function"
            );
          }
          subClass.prototype = Object.create(
            superClass && superClass.prototype,
            {
              constructor: {
                value: subClass,
                writable: true,
                configurable: true,
              },
            }
          );
          Object.defineProperty(subClass, "prototype", { writable: false });
          if (superClass) _setPrototypeOf(subClass, superClass);
        }
        function _createSuper(Derived) {
          var hasNativeReflectConstruct = _isNativeReflectConstruct();
          return function _createSuperInternal() {
            var Super = _getPrototypeOf(Derived),
              result;
            if (hasNativeReflectConstruct) {
              var NewTarget = _getPrototypeOf(this).constructor;
              result = Reflect.construct(Super, arguments, NewTarget);
            } else {
              result = Super.apply(this, arguments);
            }
            return _possibleConstructorReturn(this, result);
          };
        }
        function _possibleConstructorReturn(self, call) {
          if (
            call &&
            (_typeof(call) === "object" || typeof call === "function")
          ) {
            return call;
          } else if (call !== void 0) {
            throw new TypeError(
              "Derived constructors may only return object or undefined"
            );
          }
          return _assertThisInitialized(self);
        }
        function _assertThisInitialized(self) {
          if (self === void 0) {
            throw new ReferenceError(
              "this hasn't been initialised - super() hasn't been called"
            );
          }
          return self;
        }
        function _wrapNativeSuper(Class) {
          var _cache = typeof Map === "function" ? new Map() : undefined;
          _wrapNativeSuper = function _wrapNativeSuper(Class) {
            if (Class === null || !_isNativeFunction(Class)) return Class;
            if (typeof Class !== "function") {
              throw new TypeError(
                "Super expression must either be null or a function"
              );
            }
            if (typeof _cache !== "undefined") {
              if (_cache.has(Class)) return _cache.get(Class);
              _cache.set(Class, Wrapper);
            }
            function Wrapper() {
              return _construct(
                Class,
                arguments,
                _getPrototypeOf(this).constructor
              );
            }
            Wrapper.prototype = Object.create(Class.prototype, {
              constructor: {
                value: Wrapper,
                enumerable: false,
                writable: true,
                configurable: true,
              },
            });
            return _setPrototypeOf(Wrapper, Class);
          };
          return _wrapNativeSuper(Class);
        }
        function _construct(Parent, args, Class) {
          if (_isNativeReflectConstruct()) {
            _construct = Reflect.construct;
          } else {
            _construct = function _construct(Parent, args, Class) {
              var a = [null];
              a.push.apply(a, args);
              var Constructor = Function.bind.apply(Parent, a);
              var instance = new Constructor();
              if (Class) _setPrototypeOf(instance, Class.prototype);
              return instance;
            };
          }
          return _construct.apply(null, arguments);
        }
        function _isNativeReflectConstruct() {
          if (typeof Reflect === "undefined" || !Reflect.construct)
            return false;
          if (Reflect.construct.sham) return false;
          if (typeof Proxy === "function") return true;
          try {
            Boolean.prototype.valueOf.call(
              Reflect.construct(Boolean, [], function () {})
            );
            return true;
          } catch (e) {
            return false;
          }
        }
        function _isNativeFunction(fn) {
          return Function.toString.call(fn).indexOf("[native code]") !== -1;
        }
        function _setPrototypeOf(o, p) {
          _setPrototypeOf =
            Object.setPrototypeOf ||
            function _setPrototypeOf(o, p) {
              o.__proto__ = p;
              return o;
            };
          return _setPrototypeOf(o, p);
        }
        function _getPrototypeOf(o) {
          _getPrototypeOf = Object.setPrototypeOf
            ? Object.getPrototypeOf
            : function _getPrototypeOf(o) {
                return o.__proto__ || Object.getPrototypeOf(o);
              };
          return _getPrototypeOf(o);
        }
        var ProviderRpcError = (function (_Error) {
          _inherits(ProviderRpcError, _Error);
          var _super = _createSuper(ProviderRpcError);
          function ProviderRpcError(code, message) {
            var _this;
            _classCallCheck(this, ProviderRpcError);
            _this = _super.call(this);
            _this.code = code;
            _this.message = message;
            return _this;
          }
          _createClass(ProviderRpcError, [
            {
              key: "toString",
              value: function toString() {
                return "".concat(this.message, " (").concat(this.code, ")");
              },
            },
          ]);
          return ProviderRpcError;
        })(_wrapNativeSuper(Error));
        module.exports = ProviderRpcError;
      },
      {},
    ],
    160: [
      function (require, module, exports) {
        "use strict";
        var _rpc = _interopRequireDefault(require("./rpc"));
        var _error = _interopRequireDefault(require("./error"));
        var _utils = _interopRequireDefault(require("./utils"));
        var _id_mapping = _interopRequireDefault(require("./id_mapping"));
        var _isutf = _interopRequireDefault(require("isutf8"));
        var _ethSigUtil = require("@metamask/eth-sig-util");
        var _base_provider = _interopRequireDefault(require("./base_provider"));
        function _interopRequireDefault(obj) {
          return obj && obj.__esModule ? obj : { default: obj };
        }
        function _typeof(obj) {
          "@babel/helpers - typeof";
          return (
            (_typeof =
              "function" == typeof Symbol && "symbol" == typeof Symbol.iterator
                ? function (obj) {
                    return typeof obj;
                  }
                : function (obj) {
                    return obj &&
                      "function" == typeof Symbol &&
                      obj.constructor === Symbol &&
                      obj !== Symbol.prototype
                      ? "symbol"
                      : typeof obj;
                  }),
            _typeof(obj)
          );
        }
        function _classCallCheck(instance, Constructor) {
          if (!(instance instanceof Constructor)) {
            throw new TypeError("Cannot call a class as a function");
          }
        }
        function _defineProperties(target, props) {
          for (var i = 0; i < props.length; i++) {
            var descriptor = props[i];
            descriptor.enumerable = descriptor.enumerable || false;
            descriptor.configurable = true;
            if ("value" in descriptor) descriptor.writable = true;
            Object.defineProperty(target, descriptor.key, descriptor);
          }
        }
        function _createClass(Constructor, protoProps, staticProps) {
          if (protoProps) _defineProperties(Constructor.prototype, protoProps);
          if (staticProps) _defineProperties(Constructor, staticProps);
          Object.defineProperty(Constructor, "prototype", { writable: false });
          return Constructor;
        }
        function _get() {
          if (typeof Reflect !== "undefined" && Reflect.get) {
            _get = Reflect.get;
          } else {
            _get = function _get(target, property, receiver) {
              var base = _superPropBase(target, property);
              if (!base) return;
              var desc = Object.getOwnPropertyDescriptor(base, property);
              if (desc.get) {
                return desc.get.call(arguments.length < 3 ? target : receiver);
              }
              return desc.value;
            };
          }
          return _get.apply(this, arguments);
        }
        function _superPropBase(object, property) {
          while (!Object.prototype.hasOwnProperty.call(object, property)) {
            object = _getPrototypeOf(object);
            if (object === null) break;
          }
          return object;
        }
        function _inherits(subClass, superClass) {
          if (typeof superClass !== "function" && superClass !== null) {
            throw new TypeError(
              "Super expression must either be null or a function"
            );
          }
          subClass.prototype = Object.create(
            superClass && superClass.prototype,
            {
              constructor: {
                value: subClass,
                writable: true,
                configurable: true,
              },
            }
          );
          Object.defineProperty(subClass, "prototype", { writable: false });
          if (superClass) _setPrototypeOf(subClass, superClass);
        }
        function _setPrototypeOf(o, p) {
          _setPrototypeOf =
            Object.setPrototypeOf ||
            function _setPrototypeOf(o, p) {
              o.__proto__ = p;
              return o;
            };
          return _setPrototypeOf(o, p);
        }
        function _createSuper(Derived) {
          var hasNativeReflectConstruct = _isNativeReflectConstruct();
          return function _createSuperInternal() {
            var Super = _getPrototypeOf(Derived),
              result;
            if (hasNativeReflectConstruct) {
              var NewTarget = _getPrototypeOf(this).constructor;
              result = Reflect.construct(Super, arguments, NewTarget);
            } else {
              result = Super.apply(this, arguments);
            }
            return _possibleConstructorReturn(this, result);
          };
        }
        function _possibleConstructorReturn(self, call) {
          if (
            call &&
            (_typeof(call) === "object" || typeof call === "function")
          ) {
            return call;
          } else if (call !== void 0) {
            throw new TypeError(
              "Derived constructors may only return object or undefined"
            );
          }
          return _assertThisInitialized(self);
        }
        function _assertThisInitialized(self) {
          if (self === void 0) {
            throw new ReferenceError(
              "this hasn't been initialised - super() hasn't been called"
            );
          }
          return self;
        }
        function _isNativeReflectConstruct() {
          if (typeof Reflect === "undefined" || !Reflect.construct)
            return false;
          if (Reflect.construct.sham) return false;
          if (typeof Proxy === "function") return true;
          try {
            Boolean.prototype.valueOf.call(
              Reflect.construct(Boolean, [], function () {})
            );
            return true;
          } catch (e) {
            return false;
          }
        }
        function _getPrototypeOf(o) {
          _getPrototypeOf = Object.setPrototypeOf
            ? Object.getPrototypeOf
            : function _getPrototypeOf(o) {
                return o.__proto__ || Object.getPrototypeOf(o);
              };
          return _getPrototypeOf(o);
        }
        var PosiWeb3Provider = (function (_BaseProvider) {
          _inherits(PosiWeb3Provider, _BaseProvider);
          var _super = _createSuper(PosiWeb3Provider);
          function PosiWeb3Provider(config) {
            var _this;
            _classCallCheck(this, PosiWeb3Provider);
            _this = _super.call(this, config);
            _this.setConfig(config);
            _this.providerNetwork = "ethereum";
            _this.idMapping = new _id_mapping["default"]();
            _this.callbacks = new Map();
            _this.wrapResults = new Map();
            _this.isMetaMask = !!config.ethereum.isMetaMask;
            _this.emitConnect(_this.chainId);
            return _this;
          }
          _createClass(PosiWeb3Provider, [
            {
              key: "setAddress",
              value: function setAddress(address) {
                var lowerAddress = (address || "").toLowerCase();
                this.address = lowerAddress;
                this.ready = !!address;
                try {
                  for (var i = 0; i < window.frames.length; i++) {
                    var frame = window.frames[i];
                    if (frame.ethereum && frame.ethereum.isPosi) {
                      frame.ethereum.address = lowerAddress;
                      frame.ethereum.ready = !!address;
                    }
                  }
                } catch (error) {
                  console.log(error);
                }
              },
            },
            {
              key: "setConfig",
              value: function setConfig(config) {
                this.setAddress(config.ethereum.address);
                this.networkVersion = "" + config.ethereum.chainId;
                this.chainId =
                  "0x" + (config.ethereum.chainId || 1).toString(16);
                this.rpc = new _rpc["default"](config.ethereum.rpcUrl);
                this.isDebug = !!config.isDebug;
              },
            },
            {
              key: "request",
              value: function request(payload) {
                var that = this;
                if (!(this instanceof PosiWeb3Provider)) {
                  that = window.ethereum;
                }
                return that._request(payload, false);
              },
            },
            {
              key: "isConnected",
              value: function isConnected() {
                return true;
              },
            },
            {
              key: "enable",
              value: function enable() {
                console.log(
                  "enable() is deprecated, please use window.ethereum.request({method: 'eth_requestAccounts'}) instead."
                );
                return this.request({
                  method: "eth_requestAccounts",
                  params: [],
                });
              },
            },
            {
              key: "send",
              value: function send(payload) {
                if (this.isDebug) {
                  console.log(
                    "==> send payload ".concat(JSON.stringify(payload))
                  );
                }
                var response = { jsonrpc: "2.0", id: payload.id };
                switch (payload.method) {
                  case "eth_accounts":
                    response.result = this.eth_accounts();
                    break;
                  case "eth_coinbase":
                    response.result = this.eth_coinbase();
                    break;
                  case "net_version":
                    response.result = this.net_version();
                    break;
                  case "eth_chainId":
                    response.result = this.eth_chainId();
                    break;
                  default:
                    throw new _error["default"](
                      4200,
                      "Posi does not support calling "
                        .concat(
                          payload.method,
                          " synchronously without a callback. Please provide a callback parameter to call "
                        )
                        .concat(payload.method, " asynchronously.")
                    );
                }
                return response;
              },
            },
            {
              key: "sendAsync",
              value: function sendAsync(payload, callback) {
                console.log(
                  "sendAsync(data, callback) is deprecated, please use window.ethereum.request(data) instead."
                );
                var that = this;
                if (!(this instanceof PosiWeb3Provider)) {
                  that = window.ethereum;
                }
                if (Array.isArray(payload)) {
                  Promise.all(
                    payload.map(function (_payload) {
                      return that._request(_payload);
                    })
                  )
                    .then(function (data) {
                      return callback(null, data);
                    })
                    ["catch"](function (error) {
                      return callback(error, null);
                    });
                } else {
                  that
                    ._request(payload)
                    .then(function (data) {
                      return callback(null, data);
                    })
                    ["catch"](function (error) {
                      return callback(error, null);
                    });
                }
              },
            },
            {
              key: "_request",
              value: function _request(payload) {
                var _this2 = this;
                var wrapResult =
                  arguments.length > 1 && arguments[1] !== undefined
                    ? arguments[1]
                    : true;
                this.idMapping.tryIntifyId(payload);
                if (this.isDebug) {
                  console.log(
                    "==> _request payload ".concat(JSON.stringify(payload))
                  );
                }
                this.fillJsonRpcVersion(payload);
                return new Promise(function (resolve, reject) {
                  if (!payload.id) {
                    payload.id = _utils["default"].genId();
                  }
                  _this2.callbacks.set(payload.id, function (error, data) {
                    if (error) {
                      reject(error);
                    } else {
                      resolve(data);
                    }
                  });
                  _this2.wrapResults.set(payload.id, wrapResult);
                  switch (payload.method) {
                    case "eth_accounts":
                      return _this2.sendResponse(
                        payload.id,
                        _this2.eth_accounts()
                      );
                    case "eth_coinbase":
                      return _this2.sendResponse(
                        payload.id,
                        _this2.eth_coinbase()
                      );
                    case "net_version":
                      return _this2.sendResponse(
                        payload.id,
                        _this2.net_version()
                      );
                    case "eth_chainId":
                      return _this2.sendResponse(
                        payload.id,
                        _this2.eth_chainId()
                      );
                    case "eth_sign":
                      return _this2.eth_sign(payload);
                    case "personal_sign":
                      return _this2.personal_sign(payload);
                    case "personal_ecRecover":
                      return _this2.personal_ecRecover(payload);
                    case "eth_signTypedData_v3":
                      return _this2.eth_signTypedData(
                        payload,
                        _ethSigUtil.SignTypedDataVersion.V3
                      );
                    case "eth_signTypedData":
                    case "eth_signTypedData_v4":
                      return _this2.eth_signTypedData(
                        payload,
                        _ethSigUtil.SignTypedDataVersion.V4
                      );
                    case "eth_sendTransaction":
                      return _this2.eth_sendTransaction(payload);
                    case "eth_requestAccounts":
                      return _this2.eth_requestAccounts(payload);
                    case "wallet_watchAsset":
                      return _this2.wallet_watchAsset(payload);
                    case "wallet_addEthereumChain":
                      return _this2.wallet_addEthereumChain(payload);
                    case "wallet_switchEthereumChain":
                      return _this2.wallet_switchEthereumChain(payload);
                    case "eth_newFilter":
                    case "eth_newBlockFilter":
                    case "eth_newPendingTransactionFilter":
                    case "eth_uninstallFilter":
                    case "eth_subscribe":
                      throw new _error[
                        "default"
                      ](4200, "Posi does not support calling ".concat(payload.method, ". Please use your own solution"));
                    default:
                      _this2.callbacks["delete"](payload.id);
                      _this2.wrapResults["delete"](payload.id);
                      return _this2.rpc
                        .call(payload)
                        .then(function (response) {
                          if (_this2.isDebug) {
                            console.log(
                              "<== rpc response ".concat(
                                JSON.stringify(response)
                              )
                            );
                          }
                          wrapResult
                            ? resolve(response)
                            : resolve(response.result);
                        })
                        ["catch"](reject);
                  }
                });
              },
            },
            {
              key: "fillJsonRpcVersion",
              value: function fillJsonRpcVersion(payload) {
                if (payload.jsonrpc === undefined) {
                  payload.jsonrpc = "2.0";
                }
              },
            },
            {
              key: "emitConnect",
              value: function emitConnect(chainId) {
                this.emit("connect", { chainId: chainId });
              },
            },
            {
              key: "emitChainChanged",
              value: function emitChainChanged(chainId) {
                this.emit("chainChanged", chainId);
                this.emit("networkChanged", chainId);
              },
            },
            {
              key: "eth_accounts",
              value: function eth_accounts() {
                return this.address ? [this.address] : [];
              },
            },
            {
              key: "eth_coinbase",
              value: function eth_coinbase() {
                return this.address;
              },
            },
            {
              key: "net_version",
              value: function net_version() {
                return this.networkVersion;
              },
            },
            {
              key: "eth_chainId",
              value: function eth_chainId() {
                return this.chainId;
              },
            },
            {
              key: "eth_sign",
              value: function eth_sign(payload) {
                var buffer = _utils["default"].messageToBuffer(
                  payload.params[1]
                );
                var hex = _utils["default"].bufferToHex(buffer);
                if ((0, _isutf["default"])(buffer)) {
                  this.postMessage("signPersonalMessage", payload.id, {
                    data: hex,
                  });
                } else {
                  this.postMessage("signMessage", payload.id, { data: hex });
                }
              },
            },
            {
              key: "personal_sign",
              value: function personal_sign(payload) {
                var message = payload.params[0];
                var buffer = _utils["default"].messageToBuffer(message);
                if (buffer.length === 0) {
                  var hex = _utils["default"].bufferToHex(message);
                  this.postMessage("signPersonalMessage", payload.id, {
                    data: hex,
                  });
                } else {
                  this.postMessage("signPersonalMessage", payload.id, {
                    data: message,
                  });
                }
              },
            },
            {
              key: "personal_ecRecover",
              value: function personal_ecRecover(payload) {
                this.postMessage("ecRecover", payload.id, {
                  signature: payload.params[1],
                  message: payload.params[0],
                });
              },
            },
            {
              key: "eth_signTypedData",
              value: function eth_signTypedData(payload, version) {
                var message = JSON.parse(payload.params[1]);
                var hash = _ethSigUtil.TypedDataUtils.eip712Hash(
                  message,
                  version
                );
                this.postMessage("signTypedMessage", payload.id, {
                  data: "0x" + hash.toString("hex"),
                  raw: payload.params[1],
                });
              },
            },
            {
              key: "eth_sendTransaction",
              value: function eth_sendTransaction(payload) {
                this.postMessage(
                  "signTransaction",
                  payload.id,
                  payload.params[0]
                );
              },
            },
            {
              key: "eth_requestAccounts",
              value: function eth_requestAccounts(payload) {
                this.postMessage("requestAccounts", payload.id, {});
              },
            },
            {
              key: "wallet_watchAsset",
              value: function wallet_watchAsset(payload) {
                var options = payload.params.options;
                this.postMessage("watchAsset", payload.id, {
                  type: payload.type,
                  contract: options.address,
                  symbol: options.symbol,
                  decimals: options.decimals || 0,
                });
              },
            },
            {
              key: "wallet_addEthereumChain",
              value: function wallet_addEthereumChain(payload) {
                this.postMessage(
                  "addEthereumChain",
                  payload.id,
                  payload.params[0]
                );
              },
            },
            {
              key: "wallet_switchEthereumChain",
              value: function wallet_switchEthereumChain(payload) {
                this.postMessage(
                  "switchEthereumChain",
                  payload.id,
                  payload.params[0]
                );
              },
            },
            {
              key: "postMessage",
              value: function postMessage(handler, id, data) {
                if (this.ready || handler === "requestAccounts") {
                  _get(
                    _getPrototypeOf(PosiWeb3Provider.prototype),
                    "postMessage",
                    this
                  ).call(this, handler, id, data);
                } else {
                  this.sendError(
                    id,
                    new _error["default"](4100, "provider is not ready")
                  );
                }
              },
            },
            {
              key: "sendResponse",
              value: function sendResponse(id, result) {
                var originId = this.idMapping.tryPopId(id) || id;
                var callback = this.callbacks.get(id);
                var wrapResult = this.wrapResults.get(id);
                var data = { jsonrpc: "2.0", id: originId };
                if (
                  result !== null &&
                  _typeof(result) === "object" &&
                  result.jsonrpc &&
                  result.result
                ) {
                  data.result = result.result;
                } else {
                  data.result = result;
                }
                if (this.isDebug) {
                  console.log(
                    "<== sendResponse id: "
                      .concat(id, ", result: ")
                      .concat(JSON.stringify(result), ", data: ")
                      .concat(JSON.stringify(data))
                  );
                }
                if (callback) {
                  wrapResult ? callback(null, data) : callback(null, result);
                  this.callbacks["delete"](id);
                } else {
                  console.log("callback id: ".concat(id, " not found"));
                  for (var i = 0; i < window.frames.length; i++) {
                    var frame = window.frames[i];
                    try {
                      if (frame.ethereum.callbacks.has(id)) {
                        frame.ethereum.sendResponse(id, result);
                      }
                    } catch (error) {
                      console.log(
                        "send response to frame error: ".concat(error)
                      );
                    }
                  }
                }
              },
            },
          ]);
          return PosiWeb3Provider;
        })(_base_provider["default"]);
        module.exports = PosiWeb3Provider;
      },
      {
        "./base_provider": 158,
        "./error": 159,
        "./id_mapping": 161,
        "./rpc": 163,
        "./utils": 164,
        "@metamask/eth-sig-util": 2,
        isutf8: 96,
      },
    ],
    161: [
      function (require, module, exports) {
        "use strict";
        var _utils = _interopRequireDefault(require("./utils"));
        function _interopRequireDefault(obj) {
          return obj && obj.__esModule ? obj : { default: obj };
        }
        function _classCallCheck(instance, Constructor) {
          if (!(instance instanceof Constructor)) {
            throw new TypeError("Cannot call a class as a function");
          }
        }
        function _defineProperties(target, props) {
          for (var i = 0; i < props.length; i++) {
            var descriptor = props[i];
            descriptor.enumerable = descriptor.enumerable || false;
            descriptor.configurable = true;
            if ("value" in descriptor) descriptor.writable = true;
            Object.defineProperty(target, descriptor.key, descriptor);
          }
        }
        function _createClass(Constructor, protoProps, staticProps) {
          if (protoProps) _defineProperties(Constructor.prototype, protoProps);
          if (staticProps) _defineProperties(Constructor, staticProps);
          Object.defineProperty(Constructor, "prototype", { writable: false });
          return Constructor;
        }
        var IdMapping = (function () {
          function IdMapping() {
            _classCallCheck(this, IdMapping);
            this.intIds = new Map();
          }
          _createClass(IdMapping, [
            {
              key: "tryIntifyId",
              value: function tryIntifyId(payload) {
                if (!payload.id) {
                  payload.id = _utils["default"].genId();
                  return;
                }
                if (typeof payload.id !== "number") {
                  var newId = _utils["default"].genId();
                  this.intIds.set(newId, payload.id);
                  payload.id = newId;
                }
              },
            },
            {
              key: "tryRestoreId",
              value: function tryRestoreId(payload) {
                var id = this.tryPopId(payload.id);
                if (id) {
                  payload.id = id;
                }
              },
            },
            {
              key: "tryPopId",
              value: function tryPopId(id) {
                var originId = this.intIds.get(id);
                if (originId) {
                  this.intIds["delete"](id);
                }
                return originId;
              },
            },
          ]);
          return IdMapping;
        })();
        module.exports = IdMapping;
      },
      { "./utils": 164 },
    ],
    162: [
      function (require, module, exports) {
        "use strict";
        var _ethereum_provider = _interopRequireDefault(
          require("./ethereum_provider")
        );
        function _interopRequireDefault(obj) {
          return obj && obj.__esModule ? obj : { default: obj };
        }
        window.posiwallet = {
          Provider: _ethereum_provider["default"],
          postMessage: null,
        };
      },
      { "./ethereum_provider": 160 },
    ],
    163: [
      function (require, module, exports) {
        "use strict";
        function _classCallCheck(instance, Constructor) {
          if (!(instance instanceof Constructor)) {
            throw new TypeError("Cannot call a class as a function");
          }
        }
        function _defineProperties(target, props) {
          for (var i = 0; i < props.length; i++) {
            var descriptor = props[i];
            descriptor.enumerable = descriptor.enumerable || false;
            descriptor.configurable = true;
            if ("value" in descriptor) descriptor.writable = true;
            Object.defineProperty(target, descriptor.key, descriptor);
          }
        }
        function _createClass(Constructor, protoProps, staticProps) {
          if (protoProps) _defineProperties(Constructor.prototype, protoProps);
          if (staticProps) _defineProperties(Constructor, staticProps);
          Object.defineProperty(Constructor, "prototype", { writable: false });
          return Constructor;
        }
        var RPCServer = (function () {
          function RPCServer(rpcUrl) {
            _classCallCheck(this, RPCServer);
            this.rpcUrl = rpcUrl;
          }
          _createClass(RPCServer, [
            {
              key: "getBlockNumber",
              value: function getBlockNumber() {
                return this.call({
                  jsonrpc: "2.0",
                  method: "eth_blockNumber",
                  params: [],
                }).then(function (json) {
                  return json.result;
                });
              },
            },
            {
              key: "getBlockByNumber",
              value: function getBlockByNumber(number) {
                return this.call({
                  jsonrpc: "2.0",
                  method: "eth_getBlockByNumber",
                  params: [number, false],
                }).then(function (json) {
                  return json.result;
                });
              },
            },
            {
              key: "getFilterLogs",
              value: function getFilterLogs(filter) {
                return this.call({
                  jsonrpc: "2.0",
                  method: "eth_getLogs",
                  params: [filter],
                });
              },
            },
            {
              key: "call",
              value: function call(payload) {
                return fetch(this.rpcUrl, {
                  method: "POST",
                  headers: {
                    Accept: "application/json",
                    "Content-Type": "application/json",
                  },
                  body: JSON.stringify(payload),
                })
                  .then(function (response) {
                    return response.json();
                  })
                  .then(function (json) {
                    if (!json.result && json.error) {
                      console.log("<== rpc error", json.error);
                      throw new Error(json.error.message || "rpc error");
                    }
                    return json;
                  });
              },
            },
          ]);
          return RPCServer;
        })();
        module.exports = RPCServer;
      },
      {},
    ],
    164: [
      function (require, module, exports) {
        "use strict";
        var _buffer = require("buffer");
        function _toConsumableArray(arr) {
          return (
            _arrayWithoutHoles(arr) ||
            _iterableToArray(arr) ||
            _unsupportedIterableToArray(arr) ||
            _nonIterableSpread()
          );
        }
        function _nonIterableSpread() {
          throw new TypeError(
            "Invalid attempt to spread non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method."
          );
        }
        function _unsupportedIterableToArray(o, minLen) {
          if (!o) return;
          if (typeof o === "string") return _arrayLikeToArray(o, minLen);
          var n = Object.prototype.toString.call(o).slice(8, -1);
          if (n === "Object" && o.constructor) n = o.constructor.name;
          if (n === "Map" || n === "Set") return Array.from(o);
          if (
            n === "Arguments" ||
            /^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(n)
          )
            return _arrayLikeToArray(o, minLen);
        }
        function _iterableToArray(iter) {
          if (
            (typeof Symbol !== "undefined" && iter[Symbol.iterator] != null) ||
            iter["@@iterator"] != null
          )
            return Array.from(iter);
        }
        function _arrayWithoutHoles(arr) {
          if (Array.isArray(arr)) return _arrayLikeToArray(arr);
        }
        function _arrayLikeToArray(arr, len) {
          if (len == null || len > arr.length) len = arr.length;
          for (var i = 0, arr2 = new Array(len); i < len; i++) {
            arr2[i] = arr[i];
          }
          return arr2;
        }
        function _classCallCheck(instance, Constructor) {
          if (!(instance instanceof Constructor)) {
            throw new TypeError("Cannot call a class as a function");
          }
        }
        function _defineProperties(target, props) {
          for (var i = 0; i < props.length; i++) {
            var descriptor = props[i];
            descriptor.enumerable = descriptor.enumerable || false;
            descriptor.configurable = true;
            if ("value" in descriptor) descriptor.writable = true;
            Object.defineProperty(target, descriptor.key, descriptor);
          }
        }
        function _createClass(Constructor, protoProps, staticProps) {
          if (protoProps) _defineProperties(Constructor.prototype, protoProps);
          if (staticProps) _defineProperties(Constructor, staticProps);
          Object.defineProperty(Constructor, "prototype", { writable: false });
          return Constructor;
        }
        var Utils = (function () {
          function Utils() {
            _classCallCheck(this, Utils);
          }
          _createClass(Utils, null, [
            {
              key: "genId",
              value: function genId() {
                return new Date().getTime() + Math.floor(Math.random() * 1e3);
              },
            },
            {
              key: "flatMap",
              value: function flatMap(array, func) {
                var _ref;
                return (_ref = []).concat.apply(
                  _ref,
                  _toConsumableArray(array.map(func))
                );
              },
            },
            {
              key: "intRange",
              value: function intRange(from, to) {
                if (from >= to) {
                  return [];
                }
                return new Array(to - from).fill().map(function (_, i) {
                  return i + from;
                });
              },
            },
            {
              key: "hexToInt",
              value: function hexToInt(hexString) {
                if (hexString === undefined || hexString === null) {
                  return hexString;
                }
                return Number.parseInt(hexString, 16);
              },
            },
            {
              key: "intToHex",
              value: function intToHex(_int) {
                if (_int === undefined || _int === null) {
                  return _int;
                }
                var hexString = _int.toString(16);
                return "0x" + hexString;
              },
            },
            {
              key: "messageToBuffer",
              value: function messageToBuffer(message) {
                var buffer = _buffer.Buffer.from([]);
                try {
                  if (typeof message === "string") {
                    buffer = _buffer.Buffer.from(
                      message.replace("0x", ""),
                      "hex"
                    );
                  } else {
                    buffer = _buffer.Buffer.from(message);
                  }
                } catch (err) {
                  console.log("messageToBuffer error: ".concat(err));
                }
                return buffer;
              },
            },
            {
              key: "bufferToHex",
              value: function bufferToHex(buf) {
                return "0x" + _buffer.Buffer.from(buf).toString("hex");
              },
            },
          ]);
          return Utils;
        })();
        module.exports = Utils;
      },
      { buffer: 25 },
    ],
  },
  {},
  [162]
);

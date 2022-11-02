// ignore_for_file: avoid_print
import 'dart:typed_data';

import 'package:bs58/bs58.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:kinetic/generated/lib/api.dart';
import 'package:kinetic/interfaces/create_account_options.dart';
import 'package:kinetic/interfaces/get_balance_options.dart';
import 'package:kinetic/interfaces/get_history_options.dart';
import 'package:kinetic/interfaces/get_token_accounts_options.dart';
import 'package:kinetic/interfaces/kinetic_sdk_config.dart';
import 'package:kinetic/interfaces/make_transfer_options.dart';
import 'package:kinetic/interfaces/request_airdrop_options.dart';
import 'package:kinetic/interfaces/transaction_type.dart';
import 'package:kinetic/keypair.dart';
import 'package:kinetic/kinetic_sdk.dart';
import 'package:kinetic/solana.dart';
import 'package:kinetic_demo_app/tools.dart';
import 'package:logger/logger.dart';

import 'fixtures.dart';

void main() {
  runApp(const MyApp());
}

const accountAlice = 'ALisrzsaVqciCxy8r6g7MUrPoRo3CpGxPhwBbZzqZ9bA';
const accountBob = 'BobQoPqWy5cpFioy1dMTYqNH9WpC39mkAEDJWXECoJ9y';
const mint = 'KinDesK3dYWo3R2wDk6Ucaf31tvQCCSYyL8Fuqp33GX';

KineticSdkConfig config = KineticSdkConfig(
  endpoint: 'https://sandbox.kinetic.host',
  environment: 'devnet',
  index: 1,
  logger: Logger(),
);

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late KineticSdk sdk;
  bool loading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> setupSdk() async {
    sdk = await KineticSdk.setup(config);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: setupSdk(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                const Text("Kinetic Demo"),
                const Spacer(),
                loading == false
                    ? Container()
                    : const SpinKitRing(
                        color: Colors.white,
                        size: 25.0,
                        lineWidth: 3,
                      ),
                const SizedBox(
                  width: 25,
                ),
              ],
            ),
          ),
          body: demoBody(),
        );
      },
    );
  }

  demoBody() {
    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (OverscrollIndicatorNotification overscroll) {
        overscroll.disallowIndicator();
        return true;
      },
      child: Center(
        child: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 50,
                ),
                const Text(
                  "Keypair",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
                TextButton(
                  onPressed: () async {
                    try {
                      if (loading == false) {
                        setState(() {
                          loading = true;
                        });
                        Keypair.random().then((value) {
                          if (mounted) showAlertDialog(context, "Public Key", value.publicKey.toString());

                          setState(() {
                            loading = false;
                          });
                        });
                      }
                    } catch (e) {
                      print(e);
                      setState(() {
                        loading = false;
                      });
                      if (mounted) showAlertDialog(context, "Error", e.toString());
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.deepPurpleAccent,
                    child: const Text(
                      "Random Keypair",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    try {
                      if (loading == false) {
                        setState(() {
                          loading = true;
                        });

                        final prv8 = Uint8List.fromList(aliceByteArray.sublist(0, 32));
                        final kp = await Keypair.fromByteArray(prv8);

                        if (mounted) showAlertDialog(context, "Public Key", kp.publicKey.toString());

                        setState(() {
                          loading = false;
                        });
                      }
                    } catch (e) {
                      print(e);
                      setState(() {
                        loading = false;
                      });
                      if (mounted) showAlertDialog(context, "Error", e.toString());
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.deepPurpleAccent,
                    child: const Text(
                      "From Byte Array",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    try {
                      if (loading == false) {
                        setState(() {
                          loading = true;
                        });

                        String mnemonic = Keypair.generateMnemonic();
                        Keypair kp = await Keypair.fromMnemonic(mnemonic);
                        String userPublicKey = kp.solanaPublicKey.toString();
                        if (mounted) showAlertDialog(context, "Public Key", userPublicKey);

                        setState(() {
                          loading = false;
                        });
                      }
                    } catch (e) {
                      print(e);
                      setState(() {
                        loading = false;
                      });
                      if (mounted) showAlertDialog(context, "Error", e.toString());
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.deepPurpleAccent,
                    child: const Text(
                      "From Mnemonic",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    try {
                      if (loading == false) {
                        setState(() {
                          loading = true;
                        });

                        final kp = await Keypair.derive(seed, "m/44'/501'/0'/0'");
                        if (mounted) showAlertDialog(context, "Public Key", kp.publicKey.toString());

                        setState(() {
                          loading = false;
                        });
                      }
                    } catch (e) {
                      print(e);
                      setState(() {
                        loading = false;
                      });
                      if (mounted) showAlertDialog(context, "Error", e.toString());
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.deepPurpleAccent,
                    child: const Text(
                      "Derive",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    try {
                      if (loading == false) {
                        setState(() {
                          loading = true;
                        });

                        final kp = await Keypair.fromSeed(seed);
                        if (mounted) showAlertDialog(context, "Public Key", kp.publicKey.toString());

                        setState(() {
                          loading = false;
                        });
                      }
                    } catch (e) {
                      print(e);
                      setState(() {
                        loading = false;
                      });
                      if (mounted) showAlertDialog(context, "Error", e.toString());
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.deepPurpleAccent,
                    child: const Text(
                      "From Seed",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    try {
                      if (loading == false) {
                        setState(() {
                          loading = true;
                        });

                        final prv8 = Uint8List.fromList(aliceByteArray.sublist(0, 32));

                        final kp = await Keypair.fromSecretKey(base58.encode(prv8));
                        if (mounted) showAlertDialog(context, base58.encode(prv8), kp.publicKey.toString());

                        setState(() {
                          loading = false;
                        });
                      }
                    } catch (e) {
                      print(e);
                      setState(() {
                        loading = false;
                      });
                      if (mounted) showAlertDialog(context, "Error", e.toString());
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.deepPurpleAccent,
                    child: const Text(
                      "From Secret Key",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    try {
                      if (loading == false) {
                        setState(() {
                          loading = true;
                        });
                        final mnemonic = Keypair.generateMnemonic();
                        if (mounted) showAlertDialog(context, "Mnemonic", mnemonic);

                        setState(() {
                          loading = false;
                        });
                      }
                    } catch (e) {
                      print(e);
                      setState(() {
                        loading = false;
                      });
                      if (mounted) showAlertDialog(context, "Error", e.toString());
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.deepPurpleAccent,
                    child: const Text(
                      "Generate Mnemonic",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    try {
                      if (loading == false) {
                        setState(() {
                          loading = true;
                        });
                        Keypair keypair = await Keypair.random();
                        if (mounted) showAlertDialog(context, "solanaPublicKey", keypair.solanaPublicKey.toString());

                        setState(() {
                          loading = false;
                        });
                      }
                    } catch (e) {
                      print(e);
                      setState(() {
                        loading = false;
                      });
                      if (mounted) showAlertDialog(context, "Error", e.toString());
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.deepPurpleAccent,
                    child: const Text(
                      "get solanaPublicKey",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    try {
                      if (loading == false) {
                        setState(() {
                          loading = true;
                        });
                        Keypair keypair = await Keypair.random();
                        if (mounted) {
                          showAlertDialog(context, "solanaSecretKey", (await keypair.solanaSecretKey).toString());
                        }

                        setState(() {
                          loading = false;
                        });
                      }
                    } catch (e) {
                      print(e);
                      setState(() {
                        loading = false;
                      });
                      if (mounted) showAlertDialog(context, "Error", e.toString());
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.deepPurpleAccent,
                    child: const Text(
                      "get solanaSecretKey",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  "SDK",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
                TextButton(
                  onPressed: () async {
                    try {
                      if (loading == false) {
                        setState(() {
                          loading = true;
                        });
                        final from = await Keypair.random();

                        Transaction? res = await sdk.createAccount(CreateAccountOptions(
                          owner: from,
                          mint: "KinDesK3dYWo3R2wDk6Ucaf31tvQCCSYyL8Fuqp33GX",
                          commitment: Commitment.finalized,
                        ));
                        if (mounted) showAlertDialog(context, "Create Account", res.toString());

                        setState(() {
                          loading = false;
                        });
                      }
                    } catch (e) {
                      print(e);
                      setState(() {
                        loading = false;
                      });
                      if (mounted) showAlertDialog(context, "Error", e.toString());
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.green,
                    child: const Text(
                      "Create Account",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    try {
                      if (loading == false) {
                        setState(() {
                          loading = true;
                        });

                        var kp = await Keypair.random();
                        RequestAirdropResponse? res = await sdk.requestAirdrop(
                          RequestAirdropOptions(
                            account: kp.publicKey.toString(),
                            commitment: Commitment.finalized,
                            mint: "KinDesK3dYWo3R2wDk6Ucaf31tvQCCSYyL8Fuqp33GX",
                            amount: '50000',
                          ),
                        );
                        if (mounted) showAlertDialog(context, "Request Airdrop", res.toString());

                        setState(() {
                          loading = false;
                        });
                      }
                    } catch (e) {
                      print(e);
                      setState(() {
                        loading = false;
                      });
                      if (mounted) showAlertDialog(context, "Error", e.toString());
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.green,
                    child: const Text(
                      "Request Airdrop",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    try {
                      if (loading == false) {
                        setState(() {
                          loading = true;
                        });
                        BalanceResponse? res = await sdk
                            .getBalance(GetBalanceOptions(account: "DUXaDD5FZDa9yFf83tP8Abb6z66ECiawRShejSXRMN5F"));
                        if (mounted) showAlertDialog(context, "Get Balance", res.toString());

                        setState(() {
                          loading = false;
                        });
                      }
                    } catch (e) {
                      print(e);
                      setState(() {
                        loading = false;
                      });
                      if (mounted) showAlertDialog(context, "Error", e.toString());
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.green,
                    child: const Text(
                      "Get Balance",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    try {
                      if (loading == false) {
                        setState(() {
                          loading = true;
                        });
                        String? res = await sdk.getExplorerUrl("address/$accountBob");
                        if (mounted) showAlertDialog(context, "Get Explorer Url", res.toString());

                        setState(() {
                          loading = false;
                        });
                      }
                    } catch (e) {
                      print(e);
                      setState(() {
                        loading = false;
                      });
                      if (mounted) showAlertDialog(context, "Error", e.toString());
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.green,
                    child: const Text(
                      "Get Explorer Url",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    try {
                      if (loading == false) {
                        setState(() {
                          loading = true;
                        });

                        dynamic res = await sdk.getHistory(GetHistoryOptions(
                          account: accountBob,
                          mint: mint,
                        ));
                        if (mounted) showAlertDialog(context, "Get History", res.toString());

                        setState(() {
                          loading = false;
                        });
                      }
                    } catch (e) {
                      print(e);
                      setState(() {
                        loading = false;
                      });
                      if (mounted) showAlertDialog(context, "Error", e.toString());
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.green,
                    child: const Text(
                      "Get History",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    try {
                      if (loading == false) {
                        setState(() {
                          loading = true;
                        });

                        List<String>? res = await sdk.getTokenAccounts(GetTokenAccountsOptions(
                          account: accountBob,
                          mint: mint,
                        ));

                        if (mounted) showAlertDialog(context, "Get Token Account(s)", res.toString());

                        setState(() {
                          loading = false;
                        });
                      }
                    } catch (e) {
                      print(e);
                      setState(() {
                        loading = false;
                      });
                      if (mounted) showAlertDialog(context, "Error", e.toString());
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.green,
                    child: const Text(
                      "Get Token Account(s)",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    try {
                      if (loading == false) {
                        setState(() {
                          loading = true;
                        });

                        final prv8 = Uint8List.fromList(aliceByteArray.sublist(0, 32));

                        final kp = await Keypair.fromSecretKey(base58.encode(prv8));

                        MakeTransferOptions options = MakeTransferOptions(
                            amount: "1.0",
                            destination: "AVGAggsdHmubCZLmJ94dRp98kGJu1ZsFENPTNSe3Nhfw",
                            commitment: Commitment.finalized,
                            mint: mint,
                            owner: kp,
                            referenceId: "p2p",
                            referenceType: "tx",
                            type: TransactionType.p2p);
                        dynamic res = await sdk.makeTransfer(options);

                        if (mounted) showAlertDialog(context, "Make Transfer", res.toString());

                        setState(() {
                          loading = false;
                        });
                      }
                    } catch (e) {
                      print(e);
                      setState(() {
                        loading = false;
                      });
                      if (mounted) showAlertDialog(context, "Error", e.toString());
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.green,
                    child: const Text(
                      "Make Transfer",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  "Solana",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
                TextButton(
                  onPressed: () async {
                    try {
                      if (loading == false) {
                        setState(() {
                          loading = true;
                        });

                        Solana? client = sdk.solana;
                        String? res = client.client.rpcClient.toString();

                        if (mounted) showAlertDialog(context, "Solana RPC Client Instance", res.toString());

                        setState(() {
                          loading = false;
                        });
                      }
                    } catch (e) {
                      print(e);
                      setState(() {
                        loading = false;
                      });
                      if (mounted) showAlertDialog(context, "Error", e.toString());
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.black,
                    child: const Text(
                      "Solana",
                      style: TextStyle(
                        color: Colors.greenAccent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

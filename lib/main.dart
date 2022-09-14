import 'dart:typed_data';

import 'package:bs58/bs58.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:kinetic/commitment.dart';
import 'package:kinetic/constants.dart';
import 'package:kinetic/generated/lib/api.dart';
import 'package:kinetic/interfaces/create_account_options.dart';
import 'package:kinetic/interfaces/get_balance_options.dart';
import 'package:kinetic/interfaces/get_history_options.dart';
import 'package:kinetic/interfaces/get_token_accounts_options.dart';
import 'package:kinetic/interfaces/kinetic_sdk_config.dart';
import 'package:kinetic/interfaces/kinetic_sdk_environment.dart';
import 'package:kinetic/interfaces/make_transfer_options.dart';
import 'package:kinetic/interfaces/transaction_type.dart';
import 'package:kinetic/keypair.dart';
import 'package:kinetic/kinetic_sdk.dart';
import 'package:kinetic/solana.dart';
import 'package:kinetic_demo_app/tools.dart';

void main() {
  runApp(const MyApp());
}

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

  late KineticSdk kinetic;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    kinetic = KineticSdk();
    KineticSdkConfig config = KineticSdkConfig(index: 1, environment: KineticSdkEnvironment.devnet);
    kinetic.setup(sdkConfig: config);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text("Kinetic Demo"),
            const Spacer(),
            loading == false ? Container() : const SpinKitRing(
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
                      if (kinetic.initialized && loading == false) {
                        setState(() {
                          loading = true;
                        });
                        Keypair().random().then((value) {
                          if (mounted) showAlertDialog(context, "Public Key", value.publicKey.toBase58());

                          setState(() {
                            loading = false;
                          });
                        });
                      }
                    }catch(e) {
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

                      if (kinetic.initialized && loading == false) {
                        setState(() {
                          loading = true;
                        });

                        List<int> alice = [
                          205, 213, 7, 246, 167, 206, 37, 209, 161, 129, 168, 160, 90, 103, 198, 142, 83, 177, 214, 203, 80, 29, 71, 245, 56,
                          152, 15, 8, 235, 174, 62, 79, 138, 198, 145, 111, 119, 33, 15, 237, 89, 201, 122, 89, 48, 221, 224, 71, 81, 128, 45,
                          97, 191, 105, 37, 228, 243, 238, 130, 151, 53, 221, 172, 125,
                        ];

                        final pub8 = Uint8List.fromList(alice.sublist(32,64));
                        final prv8 = Uint8List.fromList(alice.sublist(0,32));
                        final kp = await Keypair().fromByteArray(prv8);

                        if (mounted) showAlertDialog(context, "Public Key", kp.publicKey.toBase58());

                        setState(() {
                          loading = false;
                        });
                      }
                    }catch(e) {
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
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                TextButton(
                  onPressed: () async {
                    try {
                      if (kinetic.initialized && loading == false) {
                        setState(() {
                          loading = true;
                        });
                        Keypair _keypair = Keypair();
                        String mnemonic = _keypair.generateMnemonic();
                        final user = await _keypair.fromMnemonic(mnemonic);
                        String userPublicKey = _keypair.solanaPublicKey.toBase58();
                        if (mounted) showAlertDialog(context, "Public Key", userPublicKey);

                        setState(() {
                          loading = false;
                        });
                      }
                    }catch(e) {
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
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                TextButton(
                  onPressed: () async {
                    try {
                      if (kinetic.initialized && loading == false) {
                        setState(() {
                          loading = true;
                        });
                        final List<int> seed = [73, 154, 131, 152, 101, 241, 135, 12, 176, 253, 69, 248, 79, 119, 236,
                          141, 15, 53, 10, 100, 172, 234, 47, 6, 104, 234, 201, 38, 237, 93, 158, 39, 30,
                          182, 225, 86, 186, 169, 152, 229, 143, 253, 186, 146, 191, 93, 39, 209, 166, 124,
                          156, 137, 160, 128, 43, 220, 60, 14, 25, 165, 37, 150, 79, 171];

                        final kp = await Keypair().derive(seed, "m/44'/501'/0'/0'");
                        if (mounted) showAlertDialog(context, "Public Key", kp.publicKey.toBase58());

                        setState(() {
                          loading = false;
                        });
                      }
                    }catch(e) {
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
                      if (kinetic.initialized && loading == false) {
                        setState(() {
                          loading = true;
                        });
                        final List<int> seed = [73, 154, 131, 152, 101, 241, 135, 12, 176, 253, 69, 248, 79, 119, 236,
                          141, 15, 53, 10, 100, 172, 234, 47, 6, 104, 234, 201, 38, 237, 93, 158, 39, 30,
                          182, 225, 86, 186, 169, 152, 229, 143, 253, 186, 146, 191, 93, 39, 209, 166, 124,
                          156, 137, 160, 128, 43, 220, 60, 14, 25, 165, 37, 150, 79, 171];

                        final kp = await Keypair().fromSeed(seed);
                        if (mounted) showAlertDialog(context, "Public Key", kp.publicKey.toBase58());

                        setState(() {
                          loading = false;
                        });
                      }
                    }catch(e) {
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
                      if (kinetic.initialized && loading == false) {
                        setState(() {
                          loading = true;
                        });

                        List<int> alice = [
                          205, 213, 7, 246, 167, 206, 37, 209, 161, 129, 168, 160, 90, 103, 198, 142, 83, 177, 214, 203, 80, 29, 71, 245, 56,
                          152, 15, 8, 235, 174, 62, 79, 138, 198, 145, 111, 119, 33, 15, 237, 89, 201, 122, 89, 48, 221, 224, 71, 81, 128, 45,
                          97, 191, 105, 37, 228, 243, 238, 130, 151, 53, 221, 172, 125,
                        ];

                        final pub8 = Uint8List.fromList(alice.sublist(32,64));
                        final prv8 = Uint8List.fromList(alice.sublist(0,32));

                        final kp = await Keypair().fromSecretKey(base58.encode(prv8));
                        if (mounted) showAlertDialog(context, base58.encode(prv8), kp.publicKey.toBase58());

                        setState(() {
                          loading = false;
                        });
                      }
                    }catch(e) {
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
                      if (kinetic.initialized && loading == false) {
                        setState(() {
                          loading = true;
                        });
                        final m = Keypair().generateMnemonic();
                        if (mounted) showAlertDialog(context, "Mnemonic", m);

                        setState(() {
                          loading = false;
                        });
                      }
                    }catch(e) {
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
                      if (kinetic.initialized && loading == false) {
                        setState(() {
                          loading = true;
                        });
                        Keypair keypair = Keypair();
                        var r = await keypair.random();
                        if (mounted) showAlertDialog(context, "solanaPublicKey", keypair.solanaPublicKey.toBase58());

                        setState(() {
                          loading = false;
                        });
                      }
                    }catch(e) {
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
                      if (kinetic.initialized && loading == false) {
                        setState(() {
                          loading = true;
                        });
                        Keypair keypair = Keypair();
                        var r = await keypair.random();
                        if (mounted) showAlertDialog(context, "solanaSecretKey", (await keypair.solanaSecretKey).toString());

                        setState(() {
                          loading = false;
                        });
                      }
                    }catch(e) {
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

                TextButton(
                  onPressed: () async {
                    try {
                      if (kinetic.initialized && loading == false) {
                        setState(() {
                          loading = true;
                        });
                        Keypair keypair = Keypair();
                        var r = await keypair.random();
                        if (mounted) showAlertDialog(context, "solanaRawSecret", (await keypair.solanaRawSecret).toString());

                        setState(() {
                          loading = false;
                        });
                      }
                    }catch(e) {
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
                      "get solanaRawSecret",
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
                      if (kinetic.initialized && loading == false) {
                        setState(() {
                          loading = true;
                        });
                        final from = await Keypair().random();

                        CreateAccountOptions accountOptions = CreateAccountOptions(owner: from, mint: "KinDesK3dYWo3R2wDk6Ucaf31tvQCCSYyL8Fuqp33GX", commitment: Commitment.Finalized);

                        dynamic res = await kinetic.createAccount(createAccountOptions: accountOptions);
                        if (mounted) showAlertDialog(context, "Create Account", res.toString());

                        setState(() {
                          loading = false;
                        });
                      }
                    }catch(e) {
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
                      if (kinetic.initialized && loading == false) {
                        setState(() {
                          loading = true;
                        });

                        Keypair k = Keypair();
                        var kp = await k.random();
                        RequestAirdropRequest airdropRequest = RequestAirdropRequest(account: kp.publicKey.toBase58(), commitment: RequestAirdropRequestCommitmentEnum.finalized, environment: kinetic.sdkConfig.environment.name, index: kinetic.sdkConfig.index, mint: "KinDesK3dYWo3R2wDk6Ucaf31tvQCCSYyL8Fuqp33GX");
                        dynamic res = await kinetic.requestAirdrop(airdropRequest: airdropRequest);
                        if (mounted) showAlertDialog(context, "Request Airdrop", res.toString());

                        setState(() {
                          loading = false;
                        });
                      }
                    }catch(e) {
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
                      if (kinetic.initialized && loading == false) {
                        setState(() {
                          loading = true;
                        });

                        GetBalanceOptions balanceOptions = GetBalanceOptions(account: Keypair().publicKeyFromString("DUXaDD5FZDa9yFf83tP8Abb6z66ECiawRShejSXRMN5F"));
                        dynamic res = await kinetic.getBalance(balanceOptions: balanceOptions);
                        if (mounted) showAlertDialog(context, "Get Balance", res.toString());

                        setState(() {
                          loading = false;
                        });
                      }
                    }catch(e) {
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
                      if (kinetic.initialized && loading == false) {
                        setState(() {
                          loading = true;
                        });
                        Keypair keypair = Keypair();
                        var r = await keypair.random();
                        dynamic res = await kinetic.getExplorerUrl(path: "address/${Keypair().publicKeyFromString("DUXaDD5FZDa9yFf83tP8Abb6z66ECiawRShejSXRMN5F")}");
                        if (mounted) showAlertDialog(context, "Get Explorer Url", res.toString());

                        setState(() {
                          loading = false;
                        });
                      }
                    }catch(e) {
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
                      if (kinetic.initialized && loading == false) {
                        setState(() {
                          loading = true;
                        });

                        GetHistoryOptions historyOptions = GetHistoryOptions(account: Keypair().publicKeyFromString("DUXaDD5FZDa9yFf83tP8Abb6z66ECiawRShejSXRMN5F"), mint: Keypair().publicKeyFromString("KinDesK3dYWo3R2wDk6Ucaf31tvQCCSYyL8Fuqp33GX"));
                        dynamic res = await kinetic.getHistory(historyOptions: historyOptions);
                        if (mounted) showAlertDialog(context, "Get History", res.toString());

                        setState(() {
                          loading = false;
                        });
                      }
                    }catch(e) {
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
                      if (kinetic.initialized && loading == false) {
                        setState(() {
                          loading = true;
                        });

                        GetTokenAccountsOptions accountOptions = GetTokenAccountsOptions(account: Keypair().publicKeyFromString("DUXaDD5FZDa9yFf83tP8Abb6z66ECiawRShejSXRMN5F"), mint: Keypair().publicKeyFromString("KinDesK3dYWo3R2wDk6Ucaf31tvQCCSYyL8Fuqp33GX"));
                        dynamic res = await kinetic.getTokenAccounts(tokenAccountsOptions: accountOptions);

                        if (mounted) showAlertDialog(context, "Get Token Account(s)", res.toString());

                        setState(() {
                          loading = false;
                        });
                      }
                    }catch(e) {
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
                      if (kinetic.initialized && loading == false) {
                        setState(() {
                          loading = true;
                        });

                        List<int> alice = [
                          205, 213, 7, 246, 167, 206, 37, 209, 161, 129, 168, 160, 90, 103, 198, 142, 83, 177, 214, 203, 80, 29, 71, 245, 56,
                          152, 15, 8, 235, 174, 62, 79, 138, 198, 145, 111, 119, 33, 15, 237, 89, 201, 122, 89, 48, 221, 224, 71, 81, 128, 45,
                          97, 191, 105, 37, 228, 243, 238, 130, 151, 53, 221, 172, 125,
                        ];

                        final pub8 = Uint8List.fromList(alice.sublist(32,64));
                        final prv8 = Uint8List.fromList(alice.sublist(0,32));

                        final kp = await Keypair().fromSecretKey(base58.encode(prv8));

                        MakeTransferOptions makeTransferOptions = MakeTransferOptions(amount: "1.0", destination: Keypair().publicKeyFromString("AVGAggsdHmubCZLmJ94dRp98kGJu1ZsFENPTNSe3Nhfw"), commitment: MakeTransferRequestCommitmentEnum.finalized, mint: "KinDesK3dYWo3R2wDk6Ucaf31tvQCCSYyL8Fuqp33GX", owner: kp, referenceId: "p2p", referenceType: "tx", type: TransactionType.p2p);
                        dynamic res = await kinetic.makeTransfer(makeTransferOptions: makeTransferOptions, senderCreate: true);

                        if (mounted) showAlertDialog(context, "Make Transfer", res.toString());

                        setState(() {
                          loading = false;
                        });
                      }
                    }catch(e) {
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
                      if (kinetic.initialized && loading == false) {
                        setState(() {
                          loading = true;
                        });

                        Solana client = Solana(solanaRpcEndpoint: kinetic.sdkConfig.solanaRpcEndpoint, solanaWssEndpoint: kinetic.sdkConfig.solanaWssEndpoint, timeoutDuration: timeoutDuration);

                        dynamic res = client.client.rpcClient.toString();
                        if (mounted) showAlertDialog(context, "Solana RPC Client Instance", res.toString());

                        setState(() {
                          loading = false;
                        });
                      }
                    }catch(e) {
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

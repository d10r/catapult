## About

The L2 Catapult allows to _remote control_ Superfluid streams on L2s or sidechains from an L1.
With a single L1 transaction, a given amount of ERC20 tokens is bridged to the designated L2.
A receive hook on the L2 (automatically triggered as part of the bridging process) upgrades those tokens to SuperTokens and starts a stream to the designated receiver account.
It works for any pair of chains which have a Connext bridge and the Superfluid protocol deployed.
(Regardless of chains chosen, the code refers to the sending chain as _L1_ and to the receiving chain as _L2_).

For now, this requires a Safe contract with a [Zodiac Connext Module](https://github.com/gnosis/zodiac-module-connext) enabled.

This repository contains simple scripts and Dapps, alongside contracts for testing.

The easiest way to get started is to navigate to [ipns/k2k4r8k6qtabqn7j4t1zfc38ko01g9ql0ursenhgwo7fjgw4otypgca5/catapult.html](https://cloudflare-ipfs.com/ipns/k2k4r8k6qtabqn7j4t1zfc38ko01g9ql0ursenhgwo7fjgw4otypgca5/catapult.html).

Alternatively, start a local webserver and then navigate to the Dapp.
```
cd dapps
python -m SimpleHTTPServer 1337
# now navigate to http://localhost:1337/catapult.html
```

## How to use

1.  Specify your L1 (the chain you send from) and your L2 (the chain you want to stream on). You need the chainIds for both.
2.  In a terminal, navigate to the root directory of this repository and start a webserver: `python -m SimpleHTTPServer 1337`
3.  In a browser, open the Dapp http://localhost:1337/connext-module-deployer.html
4.  Connect the Dapp to a wallet with the L2 chain connected
5.  Fill the Dapp form according to the description
5.  Click "Deploy" and confirm in the wallet. A Connext Module is being deployed. Copy the address.
6.  Enable the newly deployed module in your L2 Safe: Navigate to https://app.safe.global -> "Apps" -> "Zodiac" -> "Open Safe App" -> "Custom Module", paste the Module address and select "Add Module" -> "Submit", finally confirm in your wallet.
7.  Connect your wallet to the L1 chain
8.  Now head over to the Catapult Dapp by clicking the link at the end of the final message printed by the module deployment Dapp (it already contains several argumets as URL parameters).
9.  Fill the rest of the Dapp form, send it and confirm in the wallet
10. Now wait for the bridging operation to be executed. There's a link to the related ConnextScan page allowing you to observe it.

Execution of the receiving transaction can be delayed by up to a few hours. That's because the customized receive hook prevents the bridge from using optimistic strategies available for simple ERC20 bridging operations.

In case you didn't provide enough relayer fees for the receiving tx to be executed, [check the Connext Docs for how to bump fees](https://docs.connext.network/developers/guides/estimating-fees#bumping-relayer-fees).

Reminder:
Double check all the parameters you provide. If any of the addresses or values provided are wrong or inconsistent (e.g. flowrate too high for the bridged amount), the L2 transaction may fail. Not many checks to preempt this are currently in place.

Note: you can provide arguments to the Dapp via URL parameters instead of manually filling the form. Check the html code for parameter naming.
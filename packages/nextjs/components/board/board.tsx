import { useState } from "react";
import { BOARD_STYLES } from "./style";
import { useAccount } from "wagmi";
import { useScaffoldContractRead, useScaffoldContractWrite, useScaffoldEventSubscriber } from "~~/hooks/scaffold-eth";

interface Log {
  player: string;
  detail: string;
  num: number;
}

export const Board = () => {
  const { address } = useAccount();

  const [logs, setLogs] = useState<any>([]);

  useScaffoldEventSubscriber({
    contractName: "CryptoMonopoly",
    eventName: "PlayEvent",
    listener: (data: any) => {
      setLogs([data[0].args, ...logs]);
    },
  });

  const { data: gridData } = useScaffoldContractRead({
    contractName: "CryptoMonopoly",
    functionName: "getGrid",
  });

  const { data: you } = useScaffoldContractRead({
    contractName: "CryptoMonopoly",
    functionName: "player",
    args: [address],
  });

  const { data: isPaid } = useScaffoldContractRead({
    contractName: "CryptoMonopoly",
    functionName: "isPaid",
    args: [address],
  });

  const { data: isJail } = useScaffoldContractRead({
    contractName: "CryptoMonopoly",
    functionName: "isJail",
    args: [address],
  });

  const { data: isChest } = useScaffoldContractRead({
    contractName: "CryptoMonopoly",
    functionName: "isChest",
    args: [address],
  });

  const { data: isChance } = useScaffoldContractRead({
    contractName: "CryptoMonopoly",
    functionName: "isChance",
    args: [address],
  });

  const { data: isOwnRent } = useScaffoldContractRead({
    contractName: "CryptoMonopoly",
    functionName: "isOwnRent",
    args: [address],
  });

  const { data: coinBalance } = useScaffoldContractRead({
    contractName: "CoinToken",
    functionName: "balanceOf",
    args: [address],
  });

  const { writeAsync: playGame, isLoading: playLoading } = useScaffoldContractWrite({
    contractName: "CryptoMonopoly",
    functionName: "addPlayer",
    onBlockConfirmation: txnReceipt => {
      console.log("📦 Transaction blockHash", txnReceipt.blockHash);
    },
  });

  const { writeAsync: roll, isLoading: rollLoading } = useScaffoldContractWrite({
    contractName: "CryptoMonopoly",
    functionName: "movePlayer",
    onBlockConfirmation: txnReceipt => {
      console.log("📦 Transaction blockHash", txnReceipt.blockHash);
    },
  });

  const { writeAsync: buyProperty } = useScaffoldContractWrite({
    contractName: "CryptoMonopoly",
    functionName: "buyProperty",
    onBlockConfirmation: txnReceipt => {
      console.log("📦 Transaction blockHash", txnReceipt.blockHash);
    },
  });

  const { writeAsync: leaveJail, isLoading: leaveLoading } = useScaffoldContractWrite({
    contractName: "CryptoMonopoly",
    functionName: "leaveJail",
    onBlockConfirmation: txnReceipt => {
      console.log("📦 Transaction blockHash", txnReceipt.blockHash);
    },
  });

  const { writeAsync: collectChest, isLoading: collectChestLoading } = useScaffoldContractWrite({
    contractName: "CryptoMonopoly",
    functionName: "collectChest",
    onBlockConfirmation: txnReceipt => {
      console.log("📦 Transaction blockHash", txnReceipt.blockHash);
    },
  });

  const { writeAsync: playChance, isLoading: playChanceLoading } = useScaffoldContractWrite({
    contractName: "CryptoMonopoly",
    functionName: "playChance",
    onBlockConfirmation: txnReceipt => {
      console.log("📦 Transaction blockHash", txnReceipt.blockHash);
    },
  });

  const { writeAsync: payRent, isLoading: payRentLoading } = useScaffoldContractWrite({
    contractName: "CryptoMonopoly",
    functionName: "payRent",
    onBlockConfirmation: txnReceipt => {
      console.log("📦 Transaction blockHash", txnReceipt.blockHash);
    },
  });

  return (
    <div className="mt-5">
      <div>
        <div className="flex">
          <div>
            <div className="flex justify-between">
              <h2 className="mt-4 text-3xl">Board</h2>
              <p>{(coinBalance?.toString() as any) / 10 ** 18} Coin</p>
            </div>
            <div className="relative mt-3" style={{ width: "500px", height: "600px" }}>
              <div className="grid-action">
                {!isPaid && (
                  <button
                    className="py-2 px-16 mb-1 mt-3 mr-3 bg-green-500 rounded baseline hover:bg-green-300 disabled:opacity-50"
                    onClick={() => playGame()}
                    disabled={playLoading}
                  >
                    {playLoading ? "Adding..." : "Play"}
                  </button>
                )}
                {isPaid && !isJail && !isChest && !isChance && !isOwnRent && (
                  <button
                    className="py-2 px-16 mb-1 mt-3 mr-3 bg-green-500 rounded baseline hover:bg-green-300 disabled:opacity-50"
                    onClick={() => roll()}
                    disabled={rollLoading}
                  >
                    {rollLoading ? "Rolling..." : "Roll"}
                  </button>
                )}
                {gridData &&
                  gridData[you?.toString() as any]?.owner === "0x0000000000000000000000000000000000000000" &&
                  gridData[you?.toString() as any]?.typeGrid === "Building" && (
                    <button
                      className="py-2 px-16 mb-1 mt-3 mr-3 bg-green-500 rounded baseline hover:bg-green-300 disabled:opacity-50"
                      onClick={() => buyProperty()}
                    >
                      Buy Property
                    </button>
                  )}
                {isJail && (
                  <button
                    className="py-2 px-16 mb-1 mt-3 mr-3 bg-green-500 rounded baseline hover:bg-green-300 disabled:opacity-50"
                    onClick={() => leaveJail()}
                    disabled={leaveLoading}
                  >
                    {leaveLoading ? "Escaping" : "Leave Jail"}
                  </button>
                )}
                {isChest && (
                  <button
                    className="py-2 px-16 mb-1 mt-3 mr-3 bg-green-500 rounded baseline hover:bg-green-300 disabled:opacity-50"
                    onClick={() => collectChest()}
                    disabled={collectChestLoading}
                  >
                    {collectChestLoading ? "Collecting.." : "Collect Chest"}
                  </button>
                )}
                {isChance && (
                  <button
                    className="py-2 px-16 mb-1 mt-3 mr-3 bg-green-500 rounded baseline hover:bg-green-300 disabled:opacity-50"
                    onClick={() => playChance()}
                    disabled={playChanceLoading}
                  >
                    {playChanceLoading ? "Playing..." : "Play Chance"}
                  </button>
                )}
                {isOwnRent && (
                  <button
                    className="py-2 px-16 mb-1 mt-3 mr-3 bg-green-500 rounded baseline hover:bg-green-300 disabled:opacity-50"
                    onClick={() => payRent()}
                    disabled={payRentLoading}
                  >
                    {payRentLoading ? "Paying..." : "Pay Rent"}
                  </button>
                )}
                <div>
                  {logs.map((log: Log, index: any) => (
                    <p key={index}>
                      {log.player.slice(0, 3)}...{log.player.slice(37, 42)} {log.detail} {log.num.toString()}
                    </p>
                  ))}
                </div>
              </div>
              {gridData &&
                gridData.map((item, index) => (
                  <div
                    key={index}
                    className={
                      "w-20 h-20 border border-gray-300 font-bold bg-white" + " " + BOARD_STYLES[index] || "grid-1"
                    }
                  >
                    {you?.toString() === item.id.toString() && <p className="my-0">You</p>}
                    <div className="flex my-0">
                      {item.numberOfPlayers > 0 && <p className="mr-1"># {item.numberOfPlayers.toString()} | </p>}
                      <p>
                        {item.owner !== "0x0000000000000000000000000000000000000000"
                          ? "H " + (item.rent?.toString() as any) / 10 ** 18
                          : item.typeGrid === "Building"
                          ? (item?.price?.toString() as any) / 10 ** 18
                          : item.typeGrid}
                      </p>
                    </div>
                  </div>
                ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

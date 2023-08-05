import { BOARD_STYLES } from "./style";
import { useAccount } from "wagmi";
import { useScaffoldContractRead, useScaffoldContractWrite } from "~~/hooks/scaffold-eth";

export const Board = () => {
  const { address } = useAccount();
  const { data: gridData } = useScaffoldContractRead({
    contractName: "CryptoMonopoly",
    functionName: "getGrid",
  });

  const { data: you } = useScaffoldContractRead({
    contractName: "CryptoMonopoly",
    functionName: "player",
    args: [address],
  });

  const { data: coinBalance } = useScaffoldContractRead({
    contractName: "CoinToken",
    functionName: "balanceOf",
    args: [address],
  });

  const { writeAsync: playGame } = useScaffoldContractWrite({
    contractName: "CryptoMonopoly",
    functionName: "addPlayer",
    onBlockConfirmation: txnReceipt => {
      console.log("📦 Transaction blockHash", txnReceipt.blockHash);
    },
  });

  const { writeAsync: roll } = useScaffoldContractWrite({
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

  const { writeAsync: leaveJail } = useScaffoldContractWrite({
    contractName: "CryptoMonopoly",
    functionName: "leaveJail",
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
                <button
                  className="py-2 px-16 mb-1 mt-3 mr-3 bg-green-500 rounded baseline hover:bg-green-300 disabled:opacity-50"
                  onClick={() => playGame()}
                >
                  Play
                </button>
                <button
                  className="py-2 px-16 mb-1 mt-3 mr-3 bg-green-500 rounded baseline hover:bg-green-300 disabled:opacity-50"
                  onClick={() => roll()}
                >
                  Roll
                </button>
                <button
                  className="py-2 px-16 mb-1 mt-3 mr-3 bg-green-500 rounded baseline hover:bg-green-300 disabled:opacity-50"
                  onClick={() => buyProperty()}
                >
                  Buy Property
                </button>
                <button
                  className="py-2 px-16 mb-1 mt-3 mr-3 bg-green-500 rounded baseline hover:bg-green-300 disabled:opacity-50"
                  onClick={() => leaveJail()}
                >
                  Leave Jail
                </button>
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
                          ? "H"
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

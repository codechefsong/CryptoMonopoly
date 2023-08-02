import { useAccount } from "wagmi";
import { useScaffoldContractRead, useScaffoldContractWrite } from "~~/hooks/scaffold-eth";

export const Board = () => {
  const { address } = useAccount()
  const { data: gridData } = useScaffoldContractRead({
    contractName: "CryptoMonopoly",
    functionName: "getGrid",
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

  return (
    <div className="mt-5">
      <div>
        <div className="flex">
          <div>
            <h2 className="mt-4 text-3xl">Board</h2>
            <button className="py-2 px-16 mb-1 mt-3 mr-3 bg-green-500 rounded baseline hover:bg-green-300 disabled:opacity-50" onClick={() => playGame()}>
              Play
            </button>
            <button className="py-2 px-16 mb-1 mt-3 mr-3 bg-green-500 rounded baseline hover:bg-green-300 disabled:opacity-50" onClick={() => roll()}>
              Roll
            </button>
            <div className="flex flex-wrap" style={{ width: "450px"}}>
              {gridData && gridData.map((item, index) => (
               <div
                  key={index}
                  className="w-20 h-20 border border-gray-300 flex items-center justify-center font-bold relative bg-white"
                >
                  {item.player === address && "You"}
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

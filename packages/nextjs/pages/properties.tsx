import type { NextPage } from "next";
import { useAccount } from "wagmi";
import { MetaHeader } from "~~/components/MetaHeader";
import { useScaffoldContractRead } from "~~/hooks/scaffold-eth";

const Properties: NextPage = () => {
  const { address } = useAccount();

  const { data: playerProperties } = useScaffoldContractRead({
    contractName: "CryptoMonopoly",
    functionName: "getPlayerProperties",
    args: [address],
  });

  const { data: gridData } = useScaffoldContractRead({
    contractName: "CryptoMonopoly",
    functionName: "getGrid",
  });

  return (
    <>
      <MetaHeader
        title="Properties"
        description="Properties created with 🏗 Scaffold-ETH 2, showcasing some of its features."
      >
        {/* We are importing the font this way to lighten the size of SE2. */}
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link href="https://fonts.googleapis.com/css2?family=Bai+Jamjuree&display=swap" rel="stylesheet" />
      </MetaHeader>
      <div className="flex flex-col items-center">
        <h1 className="text-3xl mt-5">Your Properties</h1>
        {playerProperties &&
          playerProperties.map((item, index) => (
            <div key={index} className="">
              <p>ID: {gridData && gridData[item?.toString() as any]?.id.toString()}</p>
              <p>Rent: {gridData && +gridData[item?.toString() as any]?.rent.toString() / 10 ** 18} Coins</p>
              <p>Level: {gridData && gridData[item?.toString() as any]?.level.toString()}</p>
            </div>
          ))}
      </div>
    </>
  );
};

export default Properties;

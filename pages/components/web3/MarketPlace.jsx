import React from "react";
import { useAccount, useContractWrite, usePrepareContractWrite } from "wagmi";
import mint1 from "./mint1.json";
export const Mint = () => {
  const { isConnected } = useAccount();

  const { config } = usePrepareContractWrite({
    address: "0x252201E532a8394b2802A2614b53cb8FF8bA8640",
    abi: [
      {
        inputs: [],
        name: "mintNFT",
        outputs: [],
        stateMutability: "nonpayable",
        type: "function",
      },
    ],
    functionName: "mintNFT",
  });
  const { write } = useContractWrite(config);

  return (
    <div style={({ width: "200px" }, { height: "300px" })}>
      {isConnected && (
        <button
          style={{ borderRadius: "20px" }}
          disabled={!write}
          onClick={() => write?.()}
        >
          MINT
        </button>
      )}
      <button>SellNFT</button>
      <button>Buy</button>
    </div>
  );
};

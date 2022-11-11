import React from "react";
import { useAccount, useContractWrite, usePrepareContractWrite } from "wagmi";
import mint1 from "./mint1.json";
export const Mint = () => {
  const { isConnected } = useAccount();

  const { config } = usePrepareContractWrite({
    address: "0xb2fdA168B938D1E65d779458F1289cF70206af49",
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
    </div>
  );
};

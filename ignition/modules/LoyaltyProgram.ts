import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const LoyaltyProgramModule = buildModule("LoyaltyProgramModule", (m) => {

  const tokenName = "Loyalty Token";
  const tokenSymbol = "LOY";
  const expirationPeriod = 31536000; // 1 year (in seconds)
  const maxRedeemablePoints = 10000;

  const LoyaltyProgram = m.contract("LoyaltyProgram", [
    "0x51816a1b29569fbB1a56825C375C254742a9c5e1", // initialOwner
    tokenName,
    tokenSymbol,
    expirationPeriod,
    maxRedeemablePoints
  ]);

  return { LoyaltyProgram };
});

export default LoyaltyProgramModule;

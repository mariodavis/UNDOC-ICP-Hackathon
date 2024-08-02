import { HttpAgent } from '@dfinity/agent';
import { idlFactory as authIdl } from '../../../backend/declarations/tender_management';

const agent = new HttpAgent();
const authCanister = new agent.canister(authIdl);

export const login = async (username, password) => {
  return await authCanister.login(username, password);
};

export const register = async (username, password, role) => {
  await authCanister.register(username, password, role);
};

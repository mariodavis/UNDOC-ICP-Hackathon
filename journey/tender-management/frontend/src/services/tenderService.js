import { HttpAgent } from '@dfinity/agent';
import { idlFactory as tenderIdl } from '../../../backend/declarations/tender_management';

const agent = new HttpAgent();
const tenderCanister = new agent.canister(tenderIdl);

export const createTender = async (title, description, end_date) => {
  await tenderCanister.create_tender(title, description, end_date);
};

export const getTenders = async () => {
  return await tenderCanister.get_tenders();
};

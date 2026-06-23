import {OpenWebViewOptions, OpenWebViewResult} from '../lib/providers/types';
import {useWafStore} from '../lib/zustand/wafStore';

export const openWebView = async (
  url: string,
  options?: OpenWebViewOptions,
): Promise<OpenWebViewResult> => {
  return new Promise((resolve, reject) => {
    console.log('Queuing WAF solver request for:', url);
    useWafStore.getState().enqueue({
      url,
      ...options,
      resolve,
      reject,
    });
  });
};

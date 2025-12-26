import axios from "axios";
import { baseURL } from "@/constance/config";
const http = axios.create({
  baseURL: baseURL,
  timeout: 1000 * 60,
});
http.interceptors.request.use((config) => {
  return config;
});
http.interceptors.response.use(
  (res) => {
    console.log(`res.data ==>`, res.data);
    return res.data;
  },
  (e) => {
    return Promise.reject(e);
  }
);
export default http;

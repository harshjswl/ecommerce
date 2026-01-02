import axios from "axios";

const API = axios.create({
  baseURL: "http://13.235.63.94:8080/api",
});
delete API.defaults.headers.common["Authorization"];
export default API;

import datepicker from "js-datepicker";
import { dtsel } from "./dtsel";

try { // only when needed
  const instance = new dtsel.DTS('input[id="pick-date"]',  {
      direction: 'BOTTOM',
      dateFormat: "yyyy-mm-dd",
      showTime: true,
      timeFormat: "HH:MM",
      cancelBlur: 10
  });
} catch(err) {}

// const opts = { 
//   showAllDates: true,
//   position: "bl",
//   formatter: (input, date, instance) => {
// 
//   }
// };
//const elem = document.querySelector("#pick-date");
//const picker = datepicker(elem, opts);


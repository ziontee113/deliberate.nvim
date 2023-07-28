const fs = require("fs");

const filePath = "tailwind.config.js";

fs.readFile(filePath, "utf8", (err, data) => {
  if (err) {
    console.error("Error reading the file:", err);
  } else {
    try {
      const parsedData = eval(data); // Evaluate the JavaScript code in the file
      const jsonString = JSON.stringify(parsedData, null, 2); // Convert the JavaScript object to JSON string with 2-space indentation
      console.log(jsonString);
    } catch (error) {
      console.error("Error parsing the JavaScript object:", error);
    }
  }
});

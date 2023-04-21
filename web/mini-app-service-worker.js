self.addEventListener("install", function (event) {
  console.log("install");
});

self.addEventListener("activate", function (event) {
  console.log("activate");
});

self.addEventListener("fetch", function (event) {
  console.log("fetch");
});

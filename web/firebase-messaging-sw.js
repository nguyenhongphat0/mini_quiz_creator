self.addEventListener("install", function (event) {
  console.log("install");
});

self.addEventListener("activate", function (event) {
  console.log("activate");
});

self.addEventListener("fetch", function (event) {
  console.log("fetch");
});

self.addEventListener("push", function (event) {
  if (event.data) {
    const data = event.data.json();
    console.log(data);
    const title = data.notification.title;
    const message = data.notification.body;
    const icon = data.notification.image;

    event.waitUntil(
      self.registration.showNotification(title, {
        body: message,
        icon: icon,
      })
    );
  } else {
    console.log("No data received with push event");
  }
});

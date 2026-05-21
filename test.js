const express = require("express");
const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});
const db = admin.firestore();
const app = express();
app.use(express.json());
app.post("/users", async (req, res) => {
  try {
    const user = {
      name: req.body.name,
      age: req.body.age
    };
    const docRef = await db.collection("users").add(user);
    res.send({
      message: "User added",
      id: docRef.id
    });
  } catch (error) {
    res.status(500).send(error);
  }
});
// ==========================================
// ROUTE 3 -> GET ALL USERS
// ==========================================
app.get("/users", async (req, res) => {
  try {
    const snapshot = await db.collection("users").get();
    let users = [];
    snapshot.forEach((doc) => {
      users.push({
        id: doc.id,
        ...doc.data()
      });
    });

    res.send(users);

  } catch (error) {
    res.status(500).send(error);
  }

});

// ==========================================
// ROUTE 4 -> DELETE USER
// ==========================================
app.delete("/users/:id", async (req, res) => {
  try {

    const id = req.params.id;

    await db.collection("users").doc(id).delete();

    res.send("User deleted");

  } catch (error) {
    res.status(500).send(error);
  }

});

app.listen(3000, () => {
  console.log("Server running on port 3000");
});
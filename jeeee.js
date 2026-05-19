const express = require('express')
const db = require('firebase-admin')
const dbcnx= require ('connexin.json')
db.initializeApp({
  credential: db.credential.cert(dbcnx)
});
const database = db.firestore()

const app=express()
app.use(express.json())
app.get("/get-all-users",getusers)
app.delete("/delete-user",deleteuser)
app.put("/update-user",updateuser)
app.post("/create-user",createuser)
 app.listen(3000,()=>{
   console.log("serveur en marche")})

const getusers=async(req,res)=>{
  try{
    const ref= database.collection('users');
    const snapshot=await ref.get();

    const users = snapshot.docs.map(doc => ({id:doc.id,...doc.data()}));
    res.json(users)
  }
  catch(error){
    console.log(error)
    res.status(500).json({error:"Internal server error"})
  }
}

const deleteuser= async(req, res)=>{
    const id = req.body.id;
    await database.collection('users').doc('id').delete();
    res.json({message:"Utilisateur supprimé"})
}
const updateuser= async(req,res)=>{
    try{
      const {id,...data}=req.body;
      await database.collection('users').doc(id).update(data);
      res.json({message:"Utilisateur mis à jour"});
    }catch(error){
      console.log(error)
      res.status(500).json({error:"Erreur du serveur"})
    }
}
const createuser = async(req, res)=>{
    try{
        const data= req.body;
        await database.collection('users').add(data);
        res.json({
            message : "Utilisateur cree",
        })
    }catch(error){
        console.log(error)
        res.status(500).json({error:"Erreur du serveur"})
    }
}
// ROTA PARA SALVAR O LOGIN


import express from "express"
import jwt from "jsonwebtoken"
import User from "../models/user.js"
import bcrypt from "bcryptjs";

const router = express.Router()

router.post("/login", async (req,res)=>{

    const {nickname,password} = req.body

    const user = await User.findOne({nickname})

    if(!user){
        return res.status(401).json({error:"user not found"})
    }

  const isMatch = await bcrypt.compare(password, user.password);

if(!isMatch){
  return res.status(401).json({ error: "invalid password" });
    }

    const token = jwt.sign(
        {id:user._id},
        process.env.JWT_SECRET,
        {expiresIn:"30d"}
    )

    res.json({token})
})

export default router;
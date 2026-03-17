// ROTA PARA SALVAR O LOGIN


import express from "express"
import jwt from "jsonwebtoken"
import User from "../models/User.js"

const router = express.Router()

router.post("/login", async (req,res)=>{

    const {email,password} = req.body

    const user = await User.findOne({email})

    if(!user){
        return res.status(401).json({error:"user not found"})
    }

    if(user.password !== password){
        return res.status(401).json({error:"invalid password"})
    }

    const token = jwt.sign(
        {id:user._id},
        process.env.JWT_SECRET,
        {expiresIn:"30d"}
    )

    res.json({token})
})

export default router;
const express = require("express");
const cors = require("cors");

const productRoutes = require("./routes/productRoutes");
const errorHandler = require("./middlewares/errorHandler");

const app = express();

app.use(cors());
app.use(express.json());

//testezão
app.get("/", (req, res) => {
  res.json({
    mensagem: "API de Catálogo de E-commerce funcionando!"
  });
});

app.use("/api/produtos", productRoutes);

app.use(errorHandler);

module.exports = app;

require("dotenv").config();

const mongoose = require("mongoose");
const Product = require("./models/Product");

const produtos = [
  {
    nome: "Camiseta Nike Dri-FIT",
    preco: 149.90,
    categoria: "Roupas",
    estoque: 30,
    descricao: "Camiseta esportiva masculina para atividades físicas.",
    especificacoes: {
      tamanho: "M",
      cor: "Preto",
      material: "Poliéster"
    }
  },
  {
    nome: "Tênis Adidas Run",
    preco: 399.90,
    categoria: "Calçados",
    estoque: 15,
    descricao: "Tênis confortável para corrida e atividades esportivas.",
    especificacoes: {
      tamanho: 42,
      cor: "Azul",
      material: "Mesh"
    }
  },
  {
    nome: "Micro-ondas Electrolux",
    preco: 699.90,
    categoria: "Eletrodomésticos",
    estoque: 10,
    descricao: "Micro-ondas com capacidade de 31 litros.",
    especificacoes: {
      voltagem: "220V",
      potencia: "1400W",
      capacidade: "31L"
    }
  },
  {
    nome: "Notebook Lenovo IdeaPad",
    preco: 3499.90,
    categoria: "Informática",
    estoque: 8,
    descricao: "Notebook para estudos, trabalho e uso diário.",
    especificacoes: {
      processador: "Intel Core i5",
      memoria: "16GB",
      armazenamento: "512GB SSD"
    }
  },
  {
    nome: "Mouse Logitech Gamer",
    preco: 199.90,
    categoria: "Informática",
    estoque: 25,
    descricao: "Mouse gamer com sensor óptico de alta precisão.",
    especificacoes: {
      dpi: 12000,
      conexao: "USB",
      botoes: 6
    }
  },
  {
    nome: "Geladeira Brastemp Frost Free",
    preco: 4299.90,
    categoria: "Eletrodomésticos",
    estoque: 5,
    descricao: "Geladeira Frost Free com grande capacidade interna.",
    especificacoes: {
      voltagem: "220V",
      capacidade: "375L",
      tecnologia: "Frost Free"
    }
  }
];

async function seed() {
  try {
    await mongoose.connect(process.env.MONGODB_URI);

    console.log("MongoDB conectado.");

    await Product.deleteMany({});

    await Product.insertMany(produtos);

    console.log(`${produtos.length} produtos cadastrados.`);

    await mongoose.connection.close();

    console.log("Seed finalizado.");
  } catch (error) {
    console.error("Erro no seed:", error);
    process.exit(1);
  }
}

seed();
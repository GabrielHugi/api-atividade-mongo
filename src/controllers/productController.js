const mongoose = require("mongoose");
const Product = require("../models/Product");

async function createProduct(req, res, next) {
  try {
    const product = await Product.create(req.body);

    return res.status(201).json(product);
  } catch (error) {
    next(error);
  }
}

async function getProducts(req, res, next) {
  try {
    const {
      categoria,
      precoMin,
      precoMax,
      q,
      limit = 10,
      skip = 0,
      ordem = "asc"
    } = req.query;

    const filtro = {};

    if (categoria) {
      filtro.categoria = {
        $eq: categoria
      };
    }

    if (precoMin || precoMax) {
      filtro.preco = {};

      if (precoMin) {
        filtro.preco.$gte = Number(precoMin);
      }

      if (precoMax) {
        filtro.preco.$lte = Number(precoMax);
      }
    }

    if (q) {
      filtro.$text = {
        $search: q
      };
    }

    const limite = Math.min(Number(limit), 100);
    const deslocamento = Number(skip);

    const sort = ordem === "desc" ? { preco: -1 } : { preco: 1 };

    const produtos = await Product.find(filtro)
      .sort(sort)
      .skip(deslocamento)
      .limit(limite);

    const total = await Product.countDocuments(filtro);

    return res.status(200).json({
      total,
      limit: limite,
      skip: deslocamento,
      ordem: ordem === "desc" ? "decrescente" : "crescente",
      produtos
    });
  } catch (error) {
    next(error);
  }
}

async function getProductById(req, res, next) {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        mensagem: "ID inválido."
      });
    }

    const product = await Product.findById(id);

    if (!product) {
      return res.status(404).json({
        mensagem: "Produto não encontrado."
      });
    }

    return res.status(200).json(product);
  } catch (error) {
    next(error);
  }
}

async function updateProduct(req, res, next) {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        mensagem: "ID inválido."
      });
    }

    const {
      nome,
      preco,
      categoria,
      descricao,
      especificacoes,
      estoque
    } = req.body;

    const atualizacoes = {};

    if (nome !== undefined) atualizacoes.nome = nome;
    if (preco !== undefined) atualizacoes.preco = preco;
    if (categoria !== undefined) atualizacoes.categoria = categoria;
    if (descricao !== undefined) atualizacoes.descricao = descricao;
    if (especificacoes !== undefined) {
      atualizacoes.especificacoes = especificacoes;
    }

    if (estoque !== undefined) {
      atualizacoes.estoque = estoque;
    }

    const product = await Product.findByIdAndUpdate(
      id,
      atualizacoes,
      {
        new: true,
        runValidators: true
      }
    );

    if (!product) {
      return res.status(404).json({
        mensagem: "Produto não encontrado."
      });
    }

    return res.status(200).json(product);
  } catch (error) {
    next(error);
  }
}

async function updateStock(req, res, next) {
  try {
    const { id } = req.params;
    const { quantidade } = req.body;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        mensagem: "ID inválido."
      });
    }

    if (
      quantidade === undefined ||
      !Number.isInteger(quantidade) ||
      quantidade === 0
    ) {
      return res.status(400).json({
        mensagem:
          "A quantidade deve ser um número inteiro diferente de zero."
      });
    }

    const product = await Product.findOneAndUpdate(
      {
        _id: id,
        estoque: {
          $gte: quantidade < 0 ? Math.abs(quantidade) : 0
        }
      },
      {
        $inc: {
          estoque: quantidade
        }
      },
      {
        new: true,
        runValidators: true
      }
    );

    if (!product) {
      return res.status(404).json({
        mensagem:
          "Produto não encontrado ou estoque insuficiente para essa operação."
      });
    }

    return res.status(200).json({
      mensagem: "Estoque atualizado com sucesso.",
      produto: product
    });
  } catch (error) {
    next(error);
  }
}

async function deleteProduct(req, res, next) {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        mensagem: "ID inválido."
      });
    }

    const product = await Product.findByIdAndDelete(id);

    if (!product) {
      return res.status(404).json({
        mensagem: "Produto não encontrado."
      });
    }

    return res.status(200).json({
      mensagem: "Produto removido com sucesso."
    });
  } catch (error) {
    next(error);
  }
}

module.exports = {
  createProduct,
  getProducts,
  getProductById,
  updateProduct,
  updateStock,
  deleteProduct
};

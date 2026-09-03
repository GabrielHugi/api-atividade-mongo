const mongoose = require("mongoose");

const productSchema = new mongoose.Schema(
  {
    nome: {
      type: String,
      required: true,
      trim: true
    },

    preco: {
      type: Number,
      required: true,
      min: 0
    },

    categoria: {
      type: String,
      required: true,
      trim: true
    },

    estoque: {
      type: Number,
      required: true,
      min: 0,
      validate: {
        validator: Number.isInteger,
        message: "O estoque deve ser um número inteiro."
      }
    },

    descricao: {
      type: String,
      default: "",
      trim: true
    },

    especificacoes: {
      type: mongoose.Schema.Types.Mixed,
      default: {}
    }
  },
  {
    timestamps: true
  }
);

// Índice de texto para busca no nome e descrição
productSchema.index({
  nome: "text",
  descricao: "text"
});

module.exports = mongoose.model("Product", productSchema);
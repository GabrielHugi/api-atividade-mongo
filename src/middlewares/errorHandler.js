function errorHandler(error, req, res, next) {
  console.error(error);

  if (error.name === "ValidationError") {
    return res.status(400).json({
      mensagem: "Erro de validação.",
      erros: Object.values(error.errors).map((erro) => erro.message)
    });
  }

  return res.status(500).json({
    mensagem: "Erro interno do servidor."
  });
}

module.exports = errorHandler;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crud Produtos',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.grey[900],
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.grey [100]), 
          bodyMedium: TextStyle(color: Colors.grey [200]),  
          bodySmall: TextStyle(color: Colors.grey [400])
        ),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String responseText = "";
  List<dynamic> produtos = [];

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3001/produtos'));

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        if (decodedResponse is List) {
          setState(() {
            produtos = decodedResponse;
            responseText = " ";
          });
        } else {
          setState(() {
            responseText = "Erro: resposta não é uma lista";
          });
        }
      } else {
        setState(() {
          responseText = "Erro ao conectar ao backend";
        });
      }
    } catch (e) {
      setState(() {
        responseText = "Erro: $e";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Produtos Cadastrados",
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 30,
          ),
        ),
        backgroundColor: Colors.grey[850],
      ),
      body: Column(
        children: [
          Text(responseText),
          Expanded(
            child: ListView.builder(
              itemCount: produtos.length,
              itemBuilder: (context, index) {
                final produto = produtos[index];
                return ListTile(
                  title: Text(
                    produto['descricao'],
                    style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                  ),
                  subtitle: Text(
                    "Preço: ${produto['preco']}",
                    style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 18,
                            ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProdutoDetalhesPage(produto: produto),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CriarProdutoPage(onCreate: fetchData)), 
          );
        },
        tooltip: 'Criar produto',
        child: Icon(Icons.add),
        backgroundColor : Colors.purple[900],
        foregroundColor : Colors.white,
      ),
    );
  }
}

class ProdutoDetalhesPage extends StatelessWidget {
  final dynamic produto;

  ProdutoDetalhesPage({required this.produto});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Detalhes de ${produto['descricao']}",
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 30,
          ),
        ),
        backgroundColor: Colors.grey[850],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Descrição: ${produto['descricao']}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                
                ),
                SizedBox(height: 20),
                Text(
                  "Preço: ${produto['preco']}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Estoque: ${produto['estoque']}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditarProdutoPage(produto: produto),
                      ),
                    );
                  },
                  child: Text(
                    "Editar Produto",
                    style: TextStyle(
                    color: Colors.black, 
                    fontSize: 18,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 38.0),
                  )
                ),
                SizedBox(height:20),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text(
                            "Confirmar Delete",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          
                          ),
                          content: Text(
                            "Você realmente deseja deletar o produto ${produto['descricao']}?",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () async {
                                await deletarProduto(produto['id'].toString());
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(builder: (context) => MyHomePage()),
                                  (Route<dynamic> route) => false,
                                );
                              },
                              child: Text(
                                "Sim",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                "Não",
                                style: TextStyle(
                                  color: Colors.blue[600],
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text(
                    "Deletar Produto",
                    style: TextStyle(
                      color: Colors.white, 
                      fontSize: 18,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 33.0),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> deletarProduto(String produtoId) async {
    await http.delete(Uri.parse('http://localhost:3001/produto/${produto['id']}'));
  }

}

class CriarProdutoPage extends StatefulWidget {
  final Function onCreate;

  CriarProdutoPage({required this.onCreate});

  @override
  _CriarProdutoPageState createState() => _CriarProdutoPageState();
}

class _CriarProdutoPageState extends State<CriarProdutoPage> {
  final _descricaoController = TextEditingController();
  final _precoController = TextEditingController();
  final _estoqueController = TextEditingController();

  Future<void> criarProduto() async {
    final response = await http.post(
      Uri.parse('http://localhost:3001/produto'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'descricao': _descricaoController.text,
        'preco': _precoController.text,
        'estoque': int.parse(_estoqueController.text),
      }),
    );

    if (response.statusCode == 201) {
      widget.onCreate(); 
      Navigator.pop(context);
    } else {
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Criar Produto",
          style: TextStyle(
                    color: Colors.grey[500], 
                    fontSize: 30,
                ),
        ),
        backgroundColor: Colors.grey[850],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _descricaoController,
              decoration: InputDecoration(labelText: "Descrição"),
            ),
            SizedBox(height:20),
            TextField(
              controller: _precoController,
              decoration: InputDecoration(labelText: "Preço"),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height:20),
            TextField(
              controller: _estoqueController,
              decoration: InputDecoration(labelText: "Estoque"),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height:20),
            ElevatedButton(
              onPressed: criarProduto,
              child: Text(
                "Criar Produto",
                style: TextStyle(
                    color: Colors.black, 
                    fontSize: 18,
                ),
              ),
              style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 38.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditarProdutoPage extends StatefulWidget {
  final dynamic produto;

  EditarProdutoPage({required this.produto});

  @override
  _EditarProdutoPageState createState() => _EditarProdutoPageState();
}

class _EditarProdutoPageState extends State<EditarProdutoPage> {
  final _descricaoController = TextEditingController();
  final _precoController = TextEditingController();
  final _estoqueController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _descricaoController.text = widget.produto['descricao'];
    _precoController.text = widget.produto['preco'].toString();
    _estoqueController.text = widget.produto['estoque'].toString();
  }

  Future<void> editarProduto() async {
    final response = await http.put(
      Uri.parse('http://localhost:3001/produto/${widget.produto['id']}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'descricao': _descricaoController.text,
        'preco': _precoController.text,
        'estoque': int.parse(_estoqueController.text),
      }),
    );

    if (response.statusCode == 200) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
    } else {
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Editar Produto",
          style: TextStyle(
                    color: Colors.grey[500], 
                    fontSize: 30,
          ),
        ),
        backgroundColor: Colors.grey[850],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _descricaoController,
              decoration: InputDecoration(labelText: "Descrição"),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height:20),
            TextField(
              controller: _precoController,
              decoration: InputDecoration(labelText: "Preço"),
              style: Theme.of(context).textTheme.bodyLarge,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height:20),
            TextField(
              controller: _estoqueController,
              decoration: InputDecoration(labelText: "Estoque"),
              style: Theme.of(context).textTheme.bodyLarge,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height:20),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: ElevatedButton(
                onPressed: editarProduto,
                child: Text(
                  "Salvar",
                  style: TextStyle(
                    color: Colors.black, 
                    fontSize: 18,
                ),                ),
                style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 38.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
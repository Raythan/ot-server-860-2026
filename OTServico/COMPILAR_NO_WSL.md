# Guia de Compilação do OTServ para WSL (Ubuntu)

Este guia detalha o processo de compilação do servidor no ambiente WSL (Subsistema do Windows para Linux) utilizando uma imagem Ubuntu.

## 1. Preparando o Ambiente WSL

Primeiro, abra o seu terminal Ubuntu no WSL. É uma boa prática garantir que todos os seus pacotes estejam atualizados.

```bash
sudo apt-get update
sudo apt-get upgrade -y
```

## 2. Instalando Dependências

O projeto possui uma série de bibliotecas que são necessárias para a compilação. Você pode instalar todas elas, juntamente com as ferramentas de compilação essenciais, com o seguinte comando:

```bash
sudo apt-get install -y \
  build-essential \
  cmake \
  libboost-date-time-dev \
  libboost-system-dev \
  libboost-filesystem-dev \
  libboost-iostreams-dev \
  libcrypto++-dev \
  liblua5.2-dev \
  libgmp-dev \
  libmysqlclient-dev \
  libpugixml-dev
```

**Nota:** Este comando instala as dependências para a versão padrão com Lua. O projeto também suporta LuaJIT, mas a instalação com `liblua5.2-dev` é a mais comum.

## 3. Compilando o Servidor

Com todas as dependências instaladas, navegue até a pasta do projeto (se já não estiver nela) e siga os passos para a compilação. É recomendado criar uma pasta separada para os arquivos de compilação, conhecida como "out-of-source build".

```bash
# Navegue até a pasta do projeto
# Ex: cd /mnt/c/GitHub/ot-server-860-2026/OTServico

# Crie e acesse a pasta de build
# Se você já tentou compilar antes e recebeu erro, recomenda-se limpar a pasta build:
# rm -rf build && mkdir build
mkdir -p build
cd build

# Execute o CMake para configurar o projeto
# A opção -DCMAKE_BUILD_TYPE=Release otimiza o executável para performance
cmake .. -DCMAKE_BUILD_TYPE=Release

# Compile o projeto utilizando todos os cores do seu processador
make -j$(nproc)
```

## 4. Executando o Servidor

Se a compilação for concluída sem erros, o executável do servidor, chamado `tfs`, estará localizado dentro da pasta `build`.

Para iniciar o servidor, execute o seguinte comando de dentro da pasta `build`:

```bash
./tfs
```

Lembre-se que o servidor precisa do `config.lua` e de toda a estrutura da pasta `data` para iniciar corretamente. Como você está executando o `tfs` de dentro da pasta `build`, ele irá procurar esses arquivos no diretório pai (a raiz do projeto), o que deve funcionar por padrão.

```
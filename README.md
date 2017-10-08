# Objetivo

O objetivo do script é automatizar os passos do processo de Build dos Sistemas que estão no GIT. 
Os passos automatizados estão descritos no arquivo passo a passo.

Observação:

```O script ainda precisa ser melhorado```


# Pré-Requisitos

- Sistema Operacional Windows;
- Perl 5 disponível em [Perl](http://strawberry-perl.googlecode.com/files/strawberry-perl-5.16.2.1-32bit.msi);
- Módulo Config::properties instalado, disponível em [Config-Properties](http://search.cpan.org/CPAN/authors/id/S/SA/SALVA/Config-Properties-1.75.tar.gz). Por padrão, o módulo Config.properties já está referênciado no script;
- As dependências de versões do JAVA e MAVEN instalados e configurados na máquina servidora;
- Deixar configurado alguma chave ssh para acesso aos repositórios, pois o processo utiliza o Git configurado no ambiente;

# Configuração

- Realizar o clone do projeto [Build_Sistemas_Git_Windows](https://github.com/andrejesusdasilva/Build_Release_Perl.git) em algum diretório. De preferência à algum 
diretório no c:\;
- Editar o arquivo **config.properties** com as seguintes informações (exemplo):

| Chave | Valor |
| ------ | ------ |
| dircloneraiz | c:\Users\user\Documents |
| java_version16 | c:\Progra~1\Java\jdk1.6.0_18 |
| java_version17 | c:\Progra~1\Java\jdk1.7.0_80 |
| java_version18 | c:\Progra~1\Java\jdk1.8.0_121 |
| mavemversion304 | c:\maven-3.0.4 |
| mavemversion325 | c:\apache-maven-3.2.5|

``` Caso surja alguma aplicação que dependa de alguma versão específica de java ou mavem, é necessário adicionar a nova chave e valor. A chave precisa ser diferente de qualquer outra e além disto criar uma nova variável apontando para o novo valor, exemplo "my $java_version7 =  $properties->getProperty('java_version17');"```

- Como foi a primeira versão, foi criado um HashMap dentro do próprio script, deixando algumas informações hardcoded no fonte. Uma melhoria poderia ser guardar as propriedades de cada aplicações
em um arquivo .xml;

- Alterar a instrução "use lib('C:\Users\user\Desktop\geraGit\Config-Properties-1.75\lib');" para o caminho onde se encontra o módulo ou instalar o módulo no windows;

# Execução do Script (exemplo)

- Realizando a build em um branch de release:
```sh
cd c:\build_sistemas_git_windows
perl compGit.pl ibk 3.04.43 release

```

- Realizando a build em um branch de develop (obrigatório passar a próxima versão):

```sh
cd c:\build_sistemas_git_windows
perl compGit.pl ibk 3.04.43 develop 3.04.44

```

- Realizando a build em um branch fora do padrão, exemplo padrao_visual (obrigatório passar a próxima versão):

```sh
cd c:\build_sistemas_git_windows
perl compGit.pl ibk 3.04.43 padrao_visual 3.04.44

```


- O merge **ours** não é realizado automaticamente para alguns branches, é feito somente o filtro dos branches de release e até o develop;
- Qualquer aplicação onde cada branch está utilizando diferentes versões do Java e Mavem, é necessário alterar o HashMap da aplicação. Atualmente não foi encontrado uma forma
mais prática de se determinar a versão do Java e Maven;
- Para os branches de develop ou outros, cuidado com o valor do último parametro, pois será o valor da versão adicionado nos arquivos poms;
- Conflitos encontrados no  ** merge ours ** para outros branches não esta travando o processo, mas o **push** não será realizado caso isso aconteça;

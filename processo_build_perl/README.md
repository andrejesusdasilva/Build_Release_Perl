# Objetivo

O objetivo do script � automatizar os passos do processo de Build dos Sistemas que est�o no GIT. 
Os passos automatizados est�o descritos no arquivo passo a passo.

Observa��o:

```O script ainda precisa ser melhorado```


# Pr�-Requisitos

- Sistema Operacional Windows;
- Perl 5 dispon�vel em [Perl](http://strawberry-perl.googlecode.com/files/strawberry-perl-5.16.2.1-32bit.msi);
- M�dulo Config::properties instalado, dispon�vel em [Config-Properties](http://search.cpan.org/CPAN/authors/id/S/SA/SALVA/Config-Properties-1.75.tar.gz). Por padr�o, o m�dulo Config.properties j� est� refer�nciado no script;
- As depend�ncias de vers�es do JAVA e MAVEN instalados e configurados na m�quina servidora;
- Deixar configurado alguma chave ssh para acesso aos reposit�rios, pois o processo utiliza o Git configurado no ambiente;

# Configura��o

- Realizar o clone do projeto [Build_Sistemas_Git_Windows](https://github.com/andrejesusdasilva/Build_Release_Perl.git) em algum diret�rio. De prefer�ncia � algum 
diret�rio no c:\;
- Editar o arquivo **config.properties** com as seguintes informa��es (exemplo):

| Chave | Valor |
| ------ | ------ |
| dircloneraiz | c:\Users\user\Documents |
| java_version16 | c:\Progra~1\Java\jdk1.6.0_18 |
| java_version17 | c:\Progra~1\Java\jdk1.7.0_80 |
| java_version18 | c:\Progra~1\Java\jdk1.8.0_121 |
| mavemversion304 | c:\maven-3.0.4 |
| mavemversion325 | c:\apache-maven-3.2.5|

``` Caso surja alguma aplica��o que dependa de alguma vers�o espec�fica de java ou mavem, � necess�rio adicionar a nova chave e valor. A chave precisa ser diferente de qualquer outra e al�m disto criar uma nova vari�vel apontando para o novo valor, exemplo "my $java_version7 =  $properties->getProperty('java_version17');"```

- Como foi a primeira vers�o, foi criado um HashMap dentro do pr�prio script, deixando algumas informa��es hardcoded no fonte. Uma melhoria poderia ser guardar as propriedades de cada aplica��es
em um arquivo .xml;

- Alterar a instru��o "use lib('C:\Users\user\Desktop\geraGit\Config-Properties-1.75\lib');" para o caminho onde se encontra o m�dulo ou instalar o m�dulo no windows;

# Execu��o do Script (exemplo)

- Realizando a build em um branch de release:
```sh
cd c:\build_sistemas_git_windows
perl compGit.pl ibk 3.04.43 release

```

- Realizando a build em um branch de develop (obrigat�rio passar a pr�xima vers�o):

```sh
cd c:\build_sistemas_git_windows
perl compGit.pl ibk 3.04.43 develop 3.04.44

```

- Realizando a build em um branch fora do padr�o, exemplo padrao_visual (obrigat�rio passar a pr�xima vers�o):

```sh
cd c:\build_sistemas_git_windows
perl compGit.pl ibk 3.04.43 padrao_visual 3.04.44

```


- O merge **ours** n�o � realizado automaticamente para alguns branches, � feito somente o filtro dos branches de release e at� o develop;
- Qualquer aplica��o onde cada branch est� utilizando diferentes vers�es do Java e Mavem, � necess�rio alterar o HashMap da aplica��o. Atualmente n�o foi encontrado uma forma
mais pr�tica de se determinar a vers�o do Java e Maven;
- Para os branches de develop ou outros, cuidado com o valor do �ltimo parametro, pois ser� o valor da vers�o adicionado nos arquivos poms;
- Conflitos encontrados no  ** merge ours ** para outros branches n�o esta travando o processo, mas o **push** n�o ser� realizado caso isso aconte�a;

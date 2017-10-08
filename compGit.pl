#!/usr/bin/perl

#Autor: André Jesus da Silva
#Objetivo do Script: Realizar o processo de Build para os sistemas que estão no Git
##[ Ficha ]##################################################
# #
# Nome: compGit.pl#
# #
# Criado em: 15/08/2017 #
# #
## Modo de usar:
## compGit.pl app versao tipo_versao (release/develop/others)


# use strict;
no warnings;
use File::Copy;
use File::Remove 'remove'; 
use File::Compare;
use File::Basename;
use Archive::Zip;
use File::Copy::Recursive qw(dircopy);
use lib('C:\Users\user\Desktop\geraGit\Config-Properties-1.75\lib');
use Config::Properties;

open PROPS, "< config.properties" or die "Houve um erro para abrir o arquivo config.properties";

my $properties = new Config::Properties();
$properties->load(*PROPS);


##------------ Informacoes properties
my $dircloneraiz = $properties->getProperty('dircloneraiz');

my $java_version7 =  $properties->getProperty('java_version17');
my $java_version8 =  $properties->getProperty('java_version18');
my $java_version6 =  $properties->getProperty('java_version16');


#versoes do mavem

my $mavem_version304 =  $properties->getProperty('mavemversion304');
my $mavem_version325 =  $properties->getProperty('mavemversion325');
##------------


#####----- Variaveismy $app;
my $versao;
my $tipobranch;
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =  localtime(time);
$time = "$hour\_$min\_$sec";my $log_file = "$dircloneraiz\\fechamento_$time.log";
my $tagversao;
my $dirrestapi;
my $dircore;
my $dirmodules;
my $dircompmavem;
my $sigla_clone;


##------------ Estrutura de dados contendo as informações de cada aplicação. Por enquanto só terá a informação do repositório no git

# my %repos = ( 'ibk' => "ibk-dev", 
	      # 'jud' => "jud-dev",
	      # 'plf' => "tm_bov_plf-dev",
	      # 'cm' => "teste-cm-dev");
$repos = {
	   
	   'ibk' => {
		      'repos' => 'ibk-dev',
		      'sigla_clone' => "ibk",
		      'java_home' => $java_version8,
		      'maven_home' => $mavem_version304,
		      'dir_build_mavem' => $dircloneraiz . "\\" . "ibk-dev"
		      		     
		     },
	    'cm' => {
		   
		      'repos' => 'teste-cm-dev',
		      'sigla_clone' => "cm",
		      'java_home' => $java_version6,
		      'maven_home' => $mavem_version304,
		      'dir_build_mavem' => $dircloneraiz . "\\" . "teste-cm-dev",

		     
		    },
	    'jud' => {
		   
		      'repos' => 'jud-dev',
		      'sigla_clone' => "jud",
		      'java_home' => $java_version8,
		      'maven_home' => $mavem_version304,
		      'dir_build_mavem' => $dircloneraiz . "\\" . "jud-dev" . "\\" . "modules",

		     
		    },
	    'mp' => {
		   
		      'repos' => 'payment-backend-dev',
		      'sigla_clone' => "pagmovel",
		      'java_home' => $java_version8,
		      'maven_home' => $mavem_version325,
		      'dir_build_mavem' => $dircloneraiz . "\\" . "payment-backend-dev",
		      
		    },
	    'portalm' => {
		   
		      'repos' => 'portal-mercedes-dev',
		      'sigla_clone' => "merc",
		      'java_home' => $java_version8,
		      'maven_home' => $mavem_version304,
		      'dir_build_mavem' => $dircloneraiz . "\\" . "portal-mercedes-dev" . "\\" . "modules",
		      
		    },
             'ibkapi' => {
		   
		      'repos' => 'ibk-rest-dev',
		      'sigla_clone' => "ibk",
		      'java_home' => $java_version8,
		      'maven_home' => $mavem_version325,
		      'dir_build_mavem' => $dircloneraiz . "\\" . "ibk-rest-dev" . "\\" . "modules",
		      
		    },	    	    	    	    	    	    
            'plf' => {
		   
		      'repos' => 'tm_bov_plf-dev',
		      'sigla_clone' => "bvmf",
		      'java_home' => $java_version7,
		      'maven_home' => $mavem_version304,
		      'dir_build_mavem' => $dircloneraiz . "\\" . "tm_bov_plf-dev" . "\\" . "modules",

		    },
	     'spb' => {
		   
		      'repos' => 'spb-dev',
		      'sigla_clone' => "spb",
		      'java_home' => $java_version7,
		      'maven_home' => $mavem_version304,
		      'dir_build_mavem' => $dircloneraiz . "\\" . "spb-dev" . "\\" . "modules",

		    }
};	      
##------------


#validar os parametros de entrada

my $ARG = @ARGV;

if (($ARG == 4) || ($ARG == 3)) {

	$app        =  $ARGV[0];#aplicacao 
	$versao     =  $ARGV[1];#versao
	$tipobranch =  $ARGV[2];#tipo do branch (release / develop / outros)
	                                                                    
	$tagversao = "v_" . join('_', split(/\./, $versao));
			#valida se a aplicacao passada como parametro se encontra no hash cadastrado 
	if ( ! exists %$repos->{$app})    { 
	    print "A aplicação não está cadastrada no Hash de aplicações";
	    exit 1;
	 } 
	
	if ($tipobranch =~ /release/){
	#chama o tipo de build release
	&build_release($app,$versao,$tipobranch);
	
	}
	elsif ($tipobranch =~ /develop/){
	#chama o tipo de build develop
	
	$proximaversao = $ARGV[3] . "-SNAPSHOT";	&build_develop($app,$versao,$tipobranch);
	
	}
	
	else{
		
	$proximaversao = $ARGV[3] . "-SNAPSHOT";
	#chama tipo de build para outros branches
	&build_others($app,$versao,$tipobranch);
	              
	}
		
		
	}
		
	
else 
{
	
	print "Modo de usar: \n";
	print "perl geraGit app versao tipo_branch\n";
	print "Tipo de branch develop e outros, aceitam mais um parametro, exemplo:\n";
	print "perl geraGit jud 7.09.03 feature/padrao_visual 7.09.04\n";
	print "Onde 7.09.03 e a versao sendo fechada\n";
	print "Onde 7.09.04 e a proxima versao, que sera atualizada nos poms\n";
	exit 1;
	
	
	
}


#retina responsável por realizar o passo de replicação após o fechamento de uma versão
sub replicacaoGit{
print `git remote update origin --prune`;@branches =  `git branch -a`;


foreach $branc(sort @branches){
	
	# next if $branc =~ /develop/;
	
	if ($branc =~ m/(origin\/(develop))/ || $branc =~ m/(origin\/release\/(.*))/){
		
		if (  "$versao" lt "$2"){
			
			push(@branches_a_replicar, scalar "$2");
		
		}
		
		
        }
}

# push(@branches_a_replicar, $versaoatual);
@branches_a_replicar = sort @branches_a_replicar;#ordena o array


foreach $branches_a_replicar(0 .. $#branches_a_replicar){
		
		$prox_replicar = $branches_a_replicar[$branches_a_replicar];
		
		next if $versao =~ /develop/;
		
		&replicacao($versao,$prox_replicar);
		
		$versao = $prox_replicar;
}
}

sub replicacao(){
                  
        ($versaoatual,$proximobranche) = @_;        
		
	print "Iniciando as replicações\n";

	if ($proximobranche =~ /develop/){
		
	print "Replicando a versao $versaoatual na $proximobranche\n";
	print `git checkout $proximobranche`;
	print `git add --all`;
	print `git reset --hard`;
	print `git pull origin $proximobranche`;
	print `git merge --no-ff -s ours release\/$versaoatual`;
	print `git push origin $proximobranche`;
	}
	else{	
	print "Replicando a versao $versaoatual na $proximobranche\n";

	print `git checkout release\/$proximobranche`;
	print `git add --all`;
	print `git reset --hard`;
	print `git pull origin release\/$proximobranche`;
	print `git merge --no-ff -s ours release\/$versaoatual`;
	print `git push origin release\/$proximobranche`;
	
	}

}
sub resolve_conflito{
	
# -s theirs
}

#subrotinas para os tipos de builds
sub build_release{
	
	 ($app,$versao,$nomebranche) = @_;
	 $nomebranche = $nomebranche . "\/" . $versao; #transforma o nome do branch para o padrao atual
	 $nomedirraiz = &validadirs($dircloneraiz);	
	 chdir $nomedirraiz;
	 
	 $dirclonerepos =  %$repos->{$app}->{repos};
         
         $dirclonereposcompleto = $dircloneraiz . "\\" . $dirclonerepos;
	
	 $inddirclonerepos = &validadirs($dirclonereposcompleto); 
	 	 
	 if ($inddirclonerepos =~ /sim/){
	 	
	   #Nao precisa fazer o clone do projeto
	   chdir $dirclonereposcompleto;
	   &exec_build_releaseGit();
	   exit 1;
	   	
	}
	 else{
	 	
	  #Precisa fazer o clone do projeto
	  $sigla_clone = %$repos->{$app}->{sigla_clone};
	  mkdir $dirclonereposcompleto;
	  print `git clone ssh://git\@stash.matera.com:7999/cm/$dirclonerepos\.git $dirclonereposcompleto`;
	  chdir $dirclonereposcompleto;
	  &exec_build_releaseGit();
	  exit 1;
	  
	}
	 
	
}#fim build_release
	
	
sub build_develop{
	
	($app,$versao,$nomebranche) = @_;
	$nomedirraiz = &validadirs($dircloneraiz);	
	chdir $nomedirraiz;
		 
	$dirclonerepos =  %$repos->{$app}->{repos};
         
        $dirclonereposcompleto = $dircloneraiz . "\\" . $dirclonerepos; 
	
	$inddirclonerepos = &validadirs($dirclonereposcompleto); 
	
	
	if ($inddirclonerepos =~ /sim/){
	 	
	   #Nao precisa fazer o clone do projeto
	   chdir $dirclonereposcompleto;
	   &exec_build_developGit();
	   exit 1;
	
	   
	
	}
	 else{
	 	
	  #Precisa fazer o clone do projeto
          $sigla_clone = %$repos->{$app}->{sigla_clone};		
	  mkdir $dirclonereposcompleto;
	  
	  print `git clone ssh://git\@stash.matera.com:7999/$sigla_clone/$dirclonerepos\.git $dirclonereposcompleto`;
	  chdir $dirclonereposcompleto;
	  &exec_build_developGit();
	  exit 1;
		
	}
	
	
	
	}	
	
sub build_others{
	
    ($app,$versao,$nomebranche) = @_;
	$nomedirraiz = &validadirs($dircloneraiz);	
	chdir $nomedirraiz;
		 
	$dirclonerepos =  %$repos->{$app}->{repos};
         
    $dirclonereposcompleto = $dircloneraiz . "\\" . $dirclonerepos; 
	
	$inddirclonerepos = &validadirs($dirclonereposcompleto); 
	
	
	if ($inddirclonerepos =~ /sim/){
	 	
	   #Nao precisa fazer o clone do projeto
	   chdir $dirclonereposcompleto;
	   &exec_build_others();
	   exit 1;
	
	   
	
	}
	 else{
	 	
	  #Precisa fazer o clone do projeto
          $sigla_clone = %$repos->{$app}->{sigla_clone};		
	  mkdir $dirclonereposcompleto;
	  
	  print `git clone ssh://git\@stash.matera.com:7999/$sigla_clone/$dirclonerepos\.git $dirclonereposcompleto`;
	  chdir $dirclonereposcompleto;
	  &exec_build_others();
	  exit 1;
		
		
	}                
	
	
	
	
	}	
	

sub validadirs{
	
	my ($dir) = @_;
	my $result;
	if( -d $dir) 
	{
	
        	
	&log("Diretorio raiz $dir ja existe\n");
	# &log("Limpando e recriando...\n");
	# remove(\1, $dir);
	# # rmtree($dir);
	# mkdir $dir;
	$result = "sim";

	}
	else
	
	{
	
	&log("Diretorio raiz $dir não existe\n");
	&log("Criando o diretorio $dir...\n\n");
	mkdir $dir;
	$result = "nao";
	

	}

#retorno para identificar se precisa fazer o clone ou nao
return $result;  
}


sub log(){
	
    open(LOG, ">>$log_file");
    my ($msg) = ($_[0]);
    print "$msg\n";
    print LOG "$msg\n";
    close(LOG);
}

sub exec_build_releaseGit{
	

   print `git remote update origin --prune`;
   print `git add --all`;
   print `git reset --hard`;
   print `git checkout $nomebranche`;
   print `git pull origin $nomebranche`;
   &mavenpom("$app","$versao");
   print `git add --all`;
   print `git commit -m "Release $versao"`;
   print `git tag $tagversao"`;
   print `git push origin $tagversao"`;
   print `git push origin $nomebranche"`;
   &replicacaoGit();
   print `git checkout  $tagversao"`;
   &buildmavem("$app");                                  
   
}


sub exec_build_others{
	
   print `git pull`;#somente para forcar o pull do repos   print `git reset --hard`;
   print `git add --all`;
   print `git reset --hard`;
   print `git checkout $nomebranche`;
   print `git pull origin $nomebranche`;
   &mavenpom("$app","$versao");
   print `git add --all`;
   print `git commit -m "Release $versao"`;
   print `git tag $tagversao"`;
   print `git push origin $tagversao"`;
   print `git push origin $nomebranche"`;
   &mavenpomproxima("$app","$proximaversao");
   print `git add --all`;
   print `git commit -m "Starting version $proximaversao"`;
   print `git push origin $nomebranche`;
   print `git checkout  $tagversao"`;
   &buildmavem("$app");                                  
  
}
sub exec_build_developGit{
	
print `git checkout develop`;
print `git add --all`;
print `git reset --hard`;
print `git pull origin develop`;
print `git checkout -b release\/$versao`;
&mavenpom("$app","$versao");
print `git add --all`;
print `git commit -m "Release $versao"`;
print `git checkout master`;
print `git add --all`;
print `git reset --hard`;
print `git pull origin master`;
print `git merge --no-ff release\/$versao`;
print `git push origin master`;
print `git tag $tagversao`;
print `git push origin $tagversao`;
print `git checkout develop`;
print `git merge --no-ff -s ours -m "Merging release\/$versao into develop using ours strategy" release\/$versao`;
&mavenpomproxima("$app","$proximaversao");
print `git add --all`;
print `git commit -m "Starting version $proximaversao"`;
print `git push origin develop`;
print `git checkout  $tagversao"`;
&buildmavem("$app");

}

sub mavenpom(){
	
	#adicionar casos especificos para os clientes no quesito de tratamento dos arquivos pom
        #algumas aplicações tem o pom fora da raiz	                                                                                       
	
	my $app = $_[0];
	my $versao = $_[1];
	
		#tratamento poms IBK
	if ($app =~ m/^ibk$/){
	
	   
	   chdir $dirclonereposcompleto;
	   #altera o pom na raiz do IBK
	   print `mvn versions:set -DnewVersion=$versao versions:commit`;
	   
		#valida se o dir iv_ibk_rest existe, se sim, altera os poms da estrutura
		if (-d $dirclonereposcompleto . "\\" . "iv_ibk_rest-api-dev"){
			
			$dirrestapi = "$dirclonereposcompleto" . "\\" . "iv_ibk_rest-api-dev";
			chdir $dirrestapi;
			print `mvn versions:set -DnewVersion=$versao versions:commit`;
			chdir $dirclonereposcompleto;
		}
		
		#faz o mesmo para a estrutura do core		# if (-d $dirclonereposcompleto . "\\" . "iv_ibk_core-dev"){
			
			# $dircore = "$dirclonereposcompleto" . "\\" . "iv_ibk_core-dev";
			# chdir $dircore;
			# print `mvn versions:set -DnewVersion=$versao versions:commit`;
			# chdir $dirclonereposcompleto;
		
		}#fim if ibk	
		#tratamento poms aplicacao CM (repositorio de teste)
        elsif ($app =~ m/^cm$/){
	
	   chdir $dirclonereposcompleto;
	   print `mvn versions:set -DnewVersion=$versao versions:commit`;
	   
	        #valida se o dir iv_ibk_rest existe, se sim, altera os poms da estrutura
		if (-d $dirclonereposcompleto . "\\" . "iv_ibk_rest-api-dev"){
				
			$dirrestapi = "$dirclonereposcompleto" . "\\" . "iv_ibk_rest-api-dev";
			
			chdir $dirrestapi;
			print `mvn versions:set -DnewVersion=$versao versions:commit`;
			chdir $dirclonereposcompleto;
		}
		
		#faz o mesmo para a estrutura do core
		# if (-d $dirclonereposcompleto . "\\" . "iv_ibk_core-dev"){
			
			# $dircore = "$dirclonereposcompleto" . "\\" . "iv_ibk_core-dev";
			# chdir $dircore;
			# print `mvn versions:set -DnewVersion=$versao versions:commit`;
			# chdir $dirclonereposcompleto;
		# }#fim if ibk

	}	
else
{
#retorna para o diretorio raiz, por padrao algumas aplicacoes rodam a partir do pom que esta na raiz, mas alguns sistemas possue outra estrutura.

$dirclonereposcompleto = %$repos->{$app}->{dir_build_mavem}; chdir $dirclonereposcompleto;

print `mvn versions:set -DnewVersion=$versao versions:commit`;
}	
}#fim da funcao mavenpom

sub mavenpomproxima(){
	
	#adicionar casos especificos para os clientes no quesito de tratamento dos arquivos pom
        #algumas aplicações tem o pom fora da raiz	                                                                                       
	
	my $app = $_[0];
	my $proxmavenpomversao = $_[1];
	
	#tratamento poms IBK
	if ($app =~ m/^ibk$/){
	
	   chdir $dirclonereposcompleto;
	   #altera o pom na raiz do IBK
	   print `mvn versions:set -DnewVersion=$proxmavenpomversao versions:commit`;
	   

		#valida se o dir iv_ibk_rest existe, se sim, altera os poms da estrutura
		if (-d $dirclonereposcompleto . "\\" . "iv_ibk_rest-api-dev"){
			
			$dirrestapi = "$dirclonereposcompleto" . "\\" . "iv_ibk_rest-api-dev";
			chdir $dirrestapi;
			print `mvn versions:set -DnewVersion=$proxmavenpomversao versions:commit`;
			chdir $dirclonereposcompleto;
		}
		
		#faz o mesmo para a estrutura do core
		# if (-d $dirclonereposcompleto . "\\" . "iv_ibk_core-dev"){
			
			# $dircore = "$dirclonereposcompleto" . "\\" . "iv_ibk_core-dev";
			# chdir $dircore;
			# print `mvn versions:set -DnewVersion=$proxmavenpomversao versions:commit`;
			# chdir $dirclonereposcompleto;
		
	# }#fim if ibk	
	}
	#tratamento poms aplicacao CM (repositorio de teste)
        elsif ($app =~ m/^cm$/){
	
	   chdir $dirclonereposcompleto;
	   print `mvn versions:set -DnewVersion=$proxmavenpomversao versions:commit`;
	   

		#valida se o dir iv_ibk_rest existe, se sim, altera os poms da estrutura
		if (-d $dirclonereposcompleto . "\\" . "iv_ibk_rest-api-dev"){
			
			$dirrestapi = "$dirclonereposcompleto" . "\\" . "iv_ibk_rest-api-dev";
			chdir $dirrestapi;
			print `mvn versions:set -DnewVersion=$proxmavenpomversao versions:commit`;
			chdir $dirclonereposcompleto;
		}
		
		#faz o mesmo para a estrutura do core
		# if (-d $dirclonereposcompleto . "\\" . "iv_ibk_core-dev"){
			
			# $dircore = "$dirclonereposcompleto" . "\\" . "iv_ibk_core-dev";
			# chdir $dircore;
			# print `mvn versions:set -DnewVersion=$proxmavenpomversao versions:commit`;
			# chdir $dirclonereposcompleto;
		# }#fim if ibk

	}
	
else

{

#retorna para o diretorio raiz, por padrao algumas aplicacoes rodam a partir do pom que esta na raiz, mas alguns sistemas possuem outra estrutura.
$dirclonereposcompleto = %$repos->{$app}->{dir_build_mavem}; 
chdir $dirclonereposcompleto;
print `mvn versions:set -DnewVersion=$proxmavenpomversao versions:commit`;

}	
}#fim da funcao mavenpom

sub buildmavem(){
	
	my $app = $_[0];
	$dircompmavem = %$repos->{$app}->{dir_build_mavem};
	chdir $dircompmavem;
		
	$ENV{'JAVA_HOME'} = %$repos->{$app}->{java_home};
	$ENV{'M2_HOME'} = %$repos->{$app}->{maven_home};

	$java_home = $ENV{'JAVA_HOME'} . "\\bin";
        $maven_home = $ENV{'M2_HOME'} . "\\bin";
     
	$ENV{'PATH'} = $java_home . ";" . $maven_home . ";" . $ENV{'PATH'};
		
	if ($app =~ m/^ibk$/){
	    print `mvn clean install -DskipTests -Pibk-all`;
	  }
	elsif ($app =~ m/^cm$/){
	    print `mvn clean install -DskipTests -Pibk-baml`;
	  }
		
        else{
	    print `mvn clean install -DskipTests -U`;
	  }

}
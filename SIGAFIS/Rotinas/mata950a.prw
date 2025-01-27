#INCLUDE "PROTHEUS.CH"
#INCLUDE "FIVEWIN.CH"
#INCLUDE "MATA950.CH"                        
#INCLUDE "SHELL.CH"
STATIC cXMLStatic := ""
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Program   �MATA950   � Autor �Eduardo Riera          � Data �17.07.1999���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Instrucao Normativa 59                                      ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function Mata950A(lAuto,aWizAux,aWizAux2)

Local aArea		:=  GetArea()
Local cTitulo		:=	STR0001 //"Instrucoes Normativas"
Local cMsg1		:=	STR0002 //"Este programa gera arquivo pr�-formatado dos lan�amentos fiscais"
Local cMsg2		:=	STR0003 //"para entrega as Secretarias da Receita Federal, atendendo ao lay-out"
Local cMsg3		:=	STR0004 //"das Instrucoes Normativas. Dever� ser executado em modo mono-usu�rio."
Local nOpcA		:= 0
Local nTotReg   	:= 0
Local cPerg		:= "MTA950"
Local cNorma		:= ""
Local cDir      := ""
Local cVar      := ""
Local cFilBack  := cFilAnt
Local nForFilial:= 0
Local cMsg      := ""
Local cNewFile  := ""
Local cDrive    := ""
Local cExt      := ""
Local cDirRec		:= "" 
Local nProcFil	:= 0
Local aProcFil	:= {.F.,cFilAnt}
Local nX		:= 0
Local aTrab		:=	{}

Local cNorCon1
Local cNorCon2
Local cNorCon3
Local cNorCon4
Local cNorChk := ''
Local aFiles := {} // Array que receber� os nomes dos arquivos
Local nCount := 0

Default lAuto := .F.
Default aWizAux :={}
Default aWizAux2 :={}

Private cDest
Private dDmainc
Private dDmaFin
Private nMoedTit := 1
Private cNrLivro
Private nMes
Private nAno
Private aReturn    := {}
Private aFilsCalc  := {}
Private aCodLido   := {} // Utilizado na rotina fFilManad (MatXMag) para avaliar os codigos da SRV que ja foram gravados no manad.txt
Private lAglFil	:= .f.  // Identifica se as obriga��es devem ser aglutinadas ou n�o

Private lAutomato	:= lAuto
Private aWizAuto	:= aWizAux
Private aWizAuto2	:= aWizAux2

// ATEN��O:
// Manter sempre um par�nteses ao final para n�o confundir as normas que est�o contidas na nomenclatura de outras normas

// Normas habilitadas para consolidar por CNPJ completo (Gest�o Corporativa)
cNorCon1 := ''				

// Normas habilitadas para consolidar por CNPJ+I.E. (Gest�o Corporativa)    
cNorCon2 := 'CADPRO/CAT102/CAT133/CAT44/CAT63_3/CAT63_4/CAT63271/CAT79/CAT85/CAT95SM/CONV115/CPRLEGAL/DAC/'
cNorCon2 += 'DAPIMG/DCIPSC/DEC5035013/DECEST/DECLAIND/DECLANRJ/GIASTBR/SCANC/SRF042/WSNFE/NFDAL/DIAMA/DIAP/DMA/DMEBA/'
cNorCon2 += 'NFEBA/EDICE/GIMCE/ICMSTRES/GIDF/GIMDF/DIADS/DIEFES/DOTGIES/DPIGO/DSTA/P1P2MG/SAPI/EDIMS/GIAMS/EDIMT/GIAMT/'
cNorCon2 += 'INDEAMT/DIEFPA/NFCPA/GIVA/EDIPE/GIAPE/GNREPE/SEF/DIEFPI/EDIPI/GIMPI/DFCGI/GIAPR/SISCRED/DIEFRJ/GIARJ/GIASTRJ/'
cNorCon2 += 'P1P2P9/PORT93/SINTEGRJ/EDIRN/GIMRN/INFISRN/GIAMRO/SIENRO/DEMRST/GIARS/GISRS03/TDFE/DIEFSC/DIMESC/EDISC/GIASC/'
cNorCon2 += 'PERDRES/SEF081SC/REDFSE/SIMPLES/DIFTO/GIAMTO/WSSINAL/GIMPB04/GIMPB05/GIMPB06/GMB2004/GUIARSB/PORT35SC/DIEFCE/'

// Normas habilitadas para consolidar por CNPJ Raiz (Gest�o Corporativa)  
cNorCon3 := 'AUDITFIS/CREXT015/DCIINDIV/DCRE/DE/LISTA/SIMPLESN/SRF325A/DNF2010/MANAD/MAPAS/NOR08655/NORMA013/NORMA034/'
cNorCon3 += 'NORMA056/NORMA071/NORMA089/NORMA242/NORMA69A/NORMA69B/NORMA69C/NORMA69D/NORMA71A/NORMA71B/NORMA71C/NORMA71D/'
cNorCon3 += 'RIEX/SINCONF/SRF1924A/SRF194B/SRF396A/SRF396B/SRF396C/SRF396D/SRF396E/CSLL036/DCCC042/IRRF029/PERDCOMP/'
cNorCon3 += 'PERDCOMT/PERDREIN/SRF0313A/SRF0313B/SRF0313C/SRF0313D/SRF0313E/SRF0313F/SRF0313G/DCMENSAL/SRF325B/SRF325C/'
cNorCon3 += 'SRF325D/DOMNOTAM/'
		
// Normas habilitadas para consolidar por CNPJ+I.E.+I.M. (Gest�o Corporativa)  
cNorCon4 := 'ANEXO_IX/DIFUBER/CSMISS/CANOAS/DDSCE/DDSRN/DEISS/DEISSCAS/DEISSITA/DEISSJOI/GISSAMAT/GISSASUB/DIRJOINV/'
cNorCon4 += 'GISSCODE/GISSCODF/GISSCON/GISSCONF/GISSFPCO/GISSPTFC/GISSPTFP/GISSPTFS/GISSPTJC/GISSPTJS/GISSPUBL/GISSTNFC/'
cNorCon4 += 'GISSTOM/GISSTOMC/GISSTOMF/GISTOMFSN/GISTOMSN/NOVAGISS/CPOMSP/DES_NFE/DES_NFS/ISSMGT/DMSETOM/ISSJOINV/ISSSJ2/'	
cNorCon4 += 'DES_NFS/GISSBEBT/NFESEMC/GISSPOAT/EISSSBNR/DEMMSMA/DMSMA/NFEAM/DESCAN/DMSSAL/DMSSALCC/DMSPDF/VVISS/ISISS/'
cNorCon4 += 'DESAG/DMSGOI/RESTGO/DIM/DSIMPER/DES_BH/DIFJF/ISSMGP/DEISSMG/ISSMONTE/ISSNOVAL/DESSR/ISSTEOFI/DESUB/ISSVARG/'
cNorCon4 += 'DMSCG/DMSCO/ISSCAC/ISSNET/DEMMS/DESSIN/ISSVG/SDFMSPA/DFMS/ISSCAMP/DMSIPOJU/ISSJABO/DSOLINDA/DSRECIFE/NFERE/'
cNorCon4 += 'ISSPI/ISSARAU/EISSP/ISSCURIT/ISSFOZ/ISSLONDR/DMSEPRE/SISS/DEISSRO/NFERIO/NFSEBM/ISSCABOF/NFSEMACA/ISSFNI/'
cNorCon4 += 'NFERJ/NFEVR/ISSRS/DMSCX/DSGRAMAD/ISSQNDEC/DMSRIOG/NFERIOG/ISSRSSL/DESSM/ISSTRIUN/DIPSJV/SEFINSC/ISSCRIC/'
cNorCon4 += 'DMSITAJ/PISCOFJO/ISSLAGES/ISSSJ/ISSSCHRO/DMESA/ISSARARA/SIGISS/ISSARU/NFEBARUE/ISSBAURU/GISBEBP/GIESCAJ/'
cNorCon4 += 'DMSCAMP/SIMPLISS/ISSITAPE/NFEIT/ISSITA/DESITA/GEIS/ISSJAC/NFEJA/ISSLIME/DSMOGI/NFEMO/EISSOS/NFEOSA/SIMPPIRA/'
cNorCon4 += 'ISSPIRAS/GISSPOAP/SIMPLPP/ISSRP/EISSSB/NFESAN/DSSANDRE/NFESA/ISSSER/DISS/DMSSO/NFSESOR/SISUMARE/ISSTAUB/'
cNorCon4 += 'ISSVOT/NFESP/DMSPAL/'

//�������������������������������������������������������������������������������������������������`�
//�Variavel "lExitPFil" utilizada para indicar ao processamento do MATA950 que a rotina irah       �
//�   utilizar a pergunta "Seleciona Filiais" para algum tratamento especifico, porem nao havera a �
//�   necessidade de criar pastas separadas para cada arquivo resultado. Um exemplo de utilizacao  �
//�   deste tratamento eh a DAPIMG, onde utiliza a pergunta para consolidar os dados de todas as   �
//�    filiais em um unico arquivo de resultado. Para se utilizar esta funcionalidade, basta       �
//�     alterar no .INI o conteudo desta variavel para .T.                                         �
//�������������������������������������������������������������������������������������������������`�
Private lExitPFil  := .F.

//����������������������������������������������������������������������������������������������Ŀ
//�Variavel "lExibeMsg" utilizada para determinar se a mensagem referente ao parametro que trata �
//�o local de destino do arquivo gerado pela instrucao normativa devera ser exibida. Por default �
//�a mensagem sera sempre exibida, caso desejar que a mensagem nao seja exibida, esta variavel   �
//�devera ter seu conteudo alterado para ".F." no arquivo ".INI"                                 �
//������������������������������������������������������������������������������������������������
Private lExibeMsg  := .T.

//��������������������������������������������������������������Ŀ
//� Montagem da Interface com o usuario                          �
//����������������������������������������������������������������
AjustaSX1()
Pergunte(cPerg,.F.)

If !lAutomato
	FormBatch(cTitulo,{OemToAnsi(cMsg1),OemToAnsi(cMsg2),OemToAnsi(cMsg3)},;
		{ { 5,.T.,{|o| Pergunte(cPerg,.T.) }},;
		{ 1,.T.,{|o| nOpcA := 1,o:oWnd:End()}},;
		{ 2,.T.,{|o| nOpca := 2,o:oWnd:End()}}})
Else
	nOpcA := 1
EndIf

If ( nOpcA==1 )
	cNorma   := AllTrim(MV_PAR03)+ ".INI"
	cDest    := AllTrim(MV_PAR04)
	cDir     := AllTrim(MV_PAR05)
	dDmainc  := MV_PAR01
	dDmaFin  := MV_PAR02
	dDataIni := MV_PAR01
	dDataFim := MV_PAR02
	nProcFil := MV_PAR06
	cNorChk  := AllTrim(MV_PAR03)+'/'	// Colocado um par�nteses para n�o confundir as normas que est�o contidas na nomenclatura de outras normas
	lAglFil	 := ( MV_PAR07 == 1 .and. nProcFil == 1 )
	
	aFilsCalc := MatFilCalc( nProcFil == 1, , , (cNorChk $ cNorCon1+cNorCon2+cNorCon3+cNorCon4 .AND. nProcFil == 1 .and. lAglFil), , IIf(cNorChk $ cNorCon4, 4, IIf(cNorChk $ cNorCon3, 3, IIf(cNorChk $ cNorCon2, 2, IIf(cNorChk $ cNorCon1, 1, 0) ) ) ) )
	
	If Empty( aFilsCalc )
		Return
	EndIf

	For nForFilial := 1 To Len( aFilsCalc )

		If aFilsCalc[ nForFilial, 1 ]

			cFilAnt  := aFilsCalc[ nForFilial, 2 ]
			MV_PAR01 := dDataIni
			MV_PAR02 := dDataFim
			
			cNewFile := cDir + cDest
			
			SplitPath(cNewFile,@cDrive,@cDir,@cDest,@cExt)

			cDir := cDrive + cDir
			cDest+= cExt
			
			IF cNorma $ cNorCon3
				If nProcFil == 1
					cDirRec := cDir + AllTrim(cFilBack) + "\"
					aProcFil := {.T.,cFilBack}
				Else
					cDirRec := cDir
					aProcFil := {.F.,cFilAnt}
				EndIf
			Else	
				If nProcFil == 1
					cDirRec := cDir + AllTrim(cFilAnt) + "\"
					aProcFil := {.T.,cFilAnt}
				Else
					cDirRec := cDir
					aProcFil := {.F.,cFilAnt}
				EndIf
			EndIF
			Makedir(cDirRec)

			dbSelectArea("SX3")
			dbSetOrder(1)
			Processa({||ProcNorma(cNorma,cDest,cDirRec,aProcFil,@aTrab,,,,,lAutomato)})
			//������������������������������������������������������������������������Ŀ
			//�Reabre os Arquivos do Modulo desprezando os abertos pela Normativa      �
			//��������������������������������������������������������������������������
			dbCloseAll()
			OpenFile(cEmpAnt)
			aTrab := {}
		EndIf
		
		If Type("lExitPFil")=="L" .And. lExitPFil
			If File(cDirRec+cDest)
				__CopyFile(cDirRec+cDest,cDir+cDest)	
				Ferase(cDirRec+cDest)
			Else
				// Move diretorio inteiro, para altera��o do nome do arquivo gerado no ".ini" ou multiplos arquivos
				ADir(cDirRec+'*.*', aFiles)
				nCount := Len( aFiles )
				For nX := 1 to nCount
					__CopyFile(cDirRec+aFiles[nX],cDir+aFiles[nX])	
					Ferase(cDirRec+aFiles[nX])	
				Next nX		
			EndIf
			DirRemove(cDirRec)
			Exit
		EndIf
	
	Next nForFilial

EndIf
//��������������������������������������������������������������Ŀ
//� Ferase no array aTrab                                        �
//����������������������������������������������������������������
For nX := 1 to Len(aTrab)
	Ferase(AllTrim(aTrab[nX][1]))
Next

dbSelectArea("SF3")
dbSetOrder(1)
//��������������������������������������������������������������Ŀ
//� Restaura area                                                �
//����������������������������������������������������������������
cFilAnt := cFilBack
RestArea(aArea)
Return(.T.)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �ReadNorma � Autor �Eduardo Riera          � Data �17.07.1999���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de Leitura dos arquivos de Instrucao Normativa       ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com o Lay-Out da Instr.Normativa                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1: Arquivo                                              ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function ReadNormaA(cNorma, lImprime, cMdb, cMaskVlr, lXml, lTSF, lQuebralin,lNfse)

Local aNorma 	:= {}
Local cLinha 	:= ""
Local aArq      := {{}}
Local aAlias 	:= {{}}//{NIL,NIL,NIL}
Local aPre	 	:= {{}}
Local aPos	 	:= {{}}
Local aPreReg	:= {{}}
Local aPosReg	:= {{}}
Local aStru  	:= {{}}
Local aConteudo	:= {{}}
Local aContReg	:= {{}}
Local aIni      := {{}}
Local cAux		:= ""
Local aArea		:= GetArea()
Local nNivel   	:= 1
Local aImprime 	:= {.F.,,,,.F.}
Local aDelimit  := {{}}
Local aConsolidado	:=	{{"cFilAnt", "cFilAnt", "", ""}}
Local aChv		:=	{{}}
Local aOrd		:=	{""}
Local cLay      := ""
Local nAt		:=	0


Default cMaskVlr	:=	""
Default cMdb 		:= 	{}
Default lImprime	:=	.F.
Default lXml		:=	.F.
Default lTSF		:=	.F.//Indica se o processamento sera via TSF ou ERP
Default lNfse		:=	.F.//Indica se o processamento sera via TSS ou ERP
Default lQuebralin  := .T.

//������������������������������������������������������������������������Ŀ
//�Estrutura do Arquivo a Ser Lido                                         �
//�                                                                        �
//�[XXX] Onde XXX eh o Alias Principal - Identifica um Registro de Arquivo�
//�(ARQ) Definicao do Nome do Arquivo TXT referente ao Bloco []            �
//�(PRE) Pre-Processamento do Registro de Arquivo                          �
//�(PREREG) Pre-Processamento para cada registro do Alias Principal        �
//�WWWWWWWWWW X YYY Z CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC �
//�|          | |   | |                                                    �
//�|          | |   | -> Conteudo                                          �
//�|          | |   | -> Numero de Decimais                                �
//�|          | | -----> Tamanho da Coluna                                 �
//�|          | -------> Formato de Gravacao ( Numerico Caracter Data      �
//�| ------------------> Nome da Coluna                                    �
//�(POSREG) Pos-Processamento para cada registro do Alias Principal        �
//�(POS) Pos-Processamento do Registro de Arquivo                          �
//�(INI:<Nome>) Normativa a ser processada apos este registro.             �
//��������������������������������������������������������������������������

//������������������������������������������������������������������������Ŀ
//�Efetua a Abertura do Arquivo NormaXXX.Ini                               �
//��������������������������������������������������������������������������
If (File(cNorma))

	If (Upper(cNorma) == "VALPR05.INI" .Or. Upper(cNorma) == "SAPI.INI") .And. FunName() == "MATA950"          
		
		If !lAutomato
			Alert(+cNorma+STR0020)   
		EndIf
		
		RestArea(aArea)
		Return(aNorma)
	EndIf 

	FT_FUse(cNorma)
	FT_FGotop()

	While ( !FT_FEof() )
		cLinha := FT_FREADLN()

		Do Case
		Case "["==SubStr(cLinha,1,1)
			If ( !Empty(aAlias[nNivel]) )
				aadd(aNorma,{ aAlias,aPre,aPreReg,aPos,aPosReg,aStru,aConteudo,aArq,aContReg,aINI, aImprime, aDelimit, aConsolidado, aChv, aOrd,cLay})
				aPre 		:= {{}}
				aPreReg 	:= {{}}
				aPos		:= {{}}
				aPosReg		:= {{}}
				aStru		:= {{}}
				aConteudo	:= {{}}
				aContReg	:= {{}}
				aINI    	:= {{}}					
				aAlias		:= {{}} //{NIL,NIL,NIL}
				nNivel   	:= 1
				aArq        := {{}}
				aDelimit 	:= {{}}
				aConsolidado:=	{{"cFilAnt", "cFilAnt", "", ""}}
				aChv		:=	{{}}
			EndIf
			nAt	:=	0
			If (nAt := At(" ",cLinha))==0
				If (nAt := At("]",cLinha))==0
					If (nAt := At("}",cLinha))==0
						nAt	:=	Len(AllTrim(cLinha))-1
					Else
						nAt	-=	2
					EndIf
				Else
					nAt	-=	2
				EndIf
			Else
				nAt	-=	2
			EndIf
				
			aAlias[nNivel] := SubStr(cLinha,2,nAt)
			
			If nNivel <= 1			
				cLay       := AllTrim(SubStr(cLinha,6,Len(cLinha)-6))
				If Len(cLay)>47
					cLay   := SubStr(cLay,1,47)+"..."
				EndIf
			EndIf
			aImprime 	:= {.F.,,,,.F.}
			aOrd		:=	{""} 
		Case "{"==SubStr(cLinha,1,1)
			nNivel++
			nAt	:=	0
			If (nAt := At(" ",cLinha))==0
				If (nAt := At("]",cLinha))==0
					If (nAt := At("}",cLinha))==0
						nAt	:=	Len(AllTrim(cLinha))-1
					Else
						nAt	-=	2
					EndIf
				Else
					nAt	-=	2
				EndIf
			Else
				nAt	-=	2
			EndIf
			aadd(aAlias,SubStr(cLinha,2,nAt))
			aadd(aPre,{})
			aadd(aPreReg,{})
			aadd(aPos,{})
			aadd(aPosReg,{})
			aadd(aStru,{})
			aadd(aConteudo,{})
			aadd(aContReg,{})
			aadd(aINI,{})
			aadd(aArq,{})
			aadd(aDelimit,{})
			aAdd(aConsolidado, {"cFilAnt", "cFilAnt", "", ""})
			aadd(aChv,{})
			aadd(aOrd,"")

			//Identifica em que ordem deve ser impresso um determinado registro no INI. Esta clausula deve ser utilizada para os blocos
			//	que nao possuem Alias, ou seja, deve ser XXX e que o bloco esteja no INI principal (nao podendo estar dentro de um outro
			//	INI chamado pelo principal. Ex: SISIF). Um exemplo de utilizacao eh para totalizador, onde os valores calculados durante o
			//	o processamento do INI deverao compor o registro HEADER, na primeira linha do meio-magnetico.
			//	- Sua clausula pode indicar TOP para o primeiro registro do meio-magnetico ou BOT (Bottom) para o ultimo registro do meio-magnetico.
			//	- Se nao for informado, sera considerado na posicao em que aparecer no INI.
			//
			//INI Utilizado: GIARS.INI
		Case "(ORD"==SubStr (cLinha,1,4)
			aOrd[nNivel]	:=	AllTrim (SubStr (cLinha, 6))

			//Esta chave eh utilizada para otimizar o while quando nao for possivel implementar um FSQUERY por exemplo, esta chave faz
			//	parte do while para a tabela passada como Alias no bloco do registro.
		Case "(CHV"==SubStr (cLinha,1,4)
			aChv[nNivel]	:=	AllTrim (SubStr (cLinha, 6))

		Case "//"==SubStr (cLinha,1,2)
			//Nao faz nada, pois eh comentario.                                        	

			//Esta clausula define uma mascara padrao para todos os campos valores gerados pela IN no meio-magnetico.
			//	Ex. MANAD.INI: @MASKVLR="@E 9999999.99"
		Case "@MASKVLR="==SubStr (cLinha,1,9)
			cMaskVlr	:=	&(AllTrim (SubStr (cLinha, 10)))

		Case "(CONSOLIDADO)"==SubStr (cLinha,1,13)
			aConsolidado[nNivel]	:=	&(AllTrim (SubStr (cLinha, 14)))

		Case "(ARQ"==SubStr(cLinha,1,4) .And.(")"==SubStr(cLinha,5,1).or.")"==SubStr(cLinha,6,1)).And. !Empty(aAlias[nNivel])
			cAux := AllTrim(SubStr(cLinha,7))
			If ("&"$cAux)
				cAux	:=	&(AllTrim(SubStr (cAux, At ("&", cAux)+1)))
			EndIf
			//
			If ( !Empty(cAux) )
				aadd(aArq[nNivel],cAux)
			EndIf
		Case "(PRE"==SubStr(cLinha,1,4) .And.(")"==SubStr(cLinha,5,1).or.")"==SubStr(cLinha,6,1)).And. !Empty(aAlias[nNivel])
			cAux := AllTrim(SubStr(cLinha,7))
			If ( !Empty(cAux) )
				aadd(aPre[nNivel],cAux)
			EndIf
		Case !lTSF .And. !lNfse  .And. "(IMP"==SubStr(cLinha,1,4) 
			aImprime	:=	&(AllTrim (AllTrim (SubStr (cLinha, 6))))

		Case !lTSF .And. !lNfse .And. "(LEG"==SubStr(cLinha,1,4)

		Case !lTSF .And. !lNfse .And. "(CMP"==SubStr(cLinha,1,4)

		Case "(DEL"==SubStr(cLinha,1,4)
			If ("&"$AllTrim (AllTrim (SubStr (cLinha, 6))))
				aDelimit[nNivel]	:=	&(SubStr (AllTrim (SubStr (cLinha, 6)),2))
			Else
				aDelimit[nNivel]	:=	AllTrim (AllTrim (SubStr (cLinha, 6)))
			EndIf

		Case "(PREREG"==SubStr(cLinha,1,7) .And. !Empty(aAlias[nNivel])
			cAux := AllTrim(SubStr(cLinha,10))
			If ( !Empty(cAux) )
				aadd(aPreReg[nNivel],cAux)
			EndIf

		Case "(POS"==SubStr(cLinha,1,4) .And.(")"==SubStr(cLinha,5,1).or.")"==SubStr(cLinha,6,1)) .And. !Empty(aAlias[nNivel])
			cAux := AllTrim(SubStr(cLinha,7))
			If ( !Empty(cAux) )
				aadd(aPos[nNivel],cAux)
			EndIf

		Case "(POSREG"==SubStr(cLinha,1,7) .And. !Empty(aAlias[nNivel])
			cAux := AllTrim(SubStr(cLinha,10))
			If ( !Empty(cAux) )
				aadd(aPosReg[nNivel],cAux)
			EndIf

		Case "(CONT"==SubStr(cLinha,1,5) .And. !Empty(aAlias[nNivel])
			cAux := AllTrim(SubStr(cLinha,7))
			If ( !Empty(cAux) )
				aadd(aContReg[nNivel],cAux)
			EndIf	

		Case "(INI:"==SubStr(cLinha,1,5)
			cAux := AllTrim(SubStr(cLinha,6))
			If ( !Empty(cAux) )
				aadd(aIni[nNivel],Left(cAux,Len(cAux)-1))
			EndIf	
		Case "@MDB="==SubStr(cLinha,1,5)
			cMdb	:=	AllTrim (SubStr (cLinha,6))
		Case "@XML"==SubStr(cLinha,1,4)
			lXml	:=	.T.
		Case "@QUEBRA"==SubStr(cLinha,1,7)
			lQuebralin	:= .F.
		OtherWise
			If !lImprime .And. aImprime[1]
				lImprime	:=	.T.
			EndIf
			If ( !Empty(aAlias[nNivel]) ) .And. !Empty(SubStr(cLinha,01,10))
				aadd(aStru[nNivel], {	SubStr(cLinha,01,10) ,; 		//Campo
					SubStr(cLinha,12,01) ,; 		//Tipo
					Val(SubStr(cLinha,14,03)) ,; 	//Tamanho
					Val(SubStr(cLinha,18,01)) })	//Decimal

				aadd(aConteudo[nNivel], SubStr(cLinha,20) )

			EndIf

		EndCase
		FT_FSkip()
	EndDo
	//������������������������������������������������������������������������Ŀ
	//�Adiciona o ultimo registro                                              �
	//��������������������������������������������������������������������������
	If ( !Empty(aAlias[nNivel]) )   
		aadd(aNorma,{ aAlias,aPre,aPreReg,aPos,aPosReg,aStru,aConteudo,aArq,aContReg,aINI, aImprime, aDelimit, aConsolidado, aChv, aOrd , cLay})
	EndIf
	//������������������������������������������������������������������������Ŀ
	//�Fecha o Arquivo NormaXXX.INI                                            �
	//��������������������������������������������������������������������������
	FT_FUse()
Else
	If lTSF .Or. lNfse
		cTSFHelp:="NORMAERRO1"+CHR(13)+CHR(10)
	Else	
		Help(" ",1,"NORMAERRO1")
	Endif
EndIf

RestArea(aArea)

Return(aNorma)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �ProcNorma � Autor �Eduardo Riera          � Data �17.07.1999���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Rotina de Processamento de Instr.Normativa                  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1: Arquivo da Normativa                                 ���
���          �ExpC2: Arquivo de Destino                                   ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function ProcNormaA(cNorma,cDest,cDir,aProcFil,aTrab,lTSF,aCfg,lNfse,aNfse,lJob)

Local aArea 	 := GetArea()
Local lImprime	 :=	.F.
Local cMdb		 :=	""
Local cMaskVlr   :=	""
Local lXml       := .F.
Local lQuebralin := .T.
Local aNorma     :=	ReadNorma(cNorma, @lImprime, @cMdb, @cMaskVlr, @lXml, lTSF, @lQuebralin,lNfse)
Local cTrab	     := CriaTrab(,.F.)+".TXT"
Local nHandle    := 0
Local nX     	 := 0
Local lApaga   	 := .T.
Local aArqSpool  := {}
Local cBuffer    := ""
Local aBufferFim := {}
Local nIndBuf    := 0
Local nExcluidos := 0
Local cPriFil	 := ''
Local nPriFil	 := 0
Local cLib     :=''
Local nRemType 	:= GetRemoteType(@cLib)
Local lHtml		:= 'HTML' $ cLib
Local cFunc			:= 'CPYS2TW'

Default  lTSF    := .F.//.F.(Default)-Processamento via ERP|.T.-Processamento via TSF
Default  lNfse   := .F.//.F.(Default)-Processamento via ERP|.T.-Processamento via TSS
Default  cDir    := ""
Default  aProcFil:= Iif(lTSF,{},Iif(lNfse,{},{.F.,cFilAnt}))
Default  aTrab	 :=	{}
Default  aCFG	 :=	{} //Variavel Especifico TSF
Default  aNfse	 := {}
Private cTSFHelp := "" //Variavel Especifico TSF

Default	lJob	 :=	.F.

nHandle          := FCreate(cTrab,0)

If ( FError() == 0 )
	//������������������������������������������������������������������������Ŀ
	//�Declara Variaveis que podem ser utilizadas nas Normativas.              �
	//��������������������������������������������������������������������������
	Private _aTotal[117]
	Private lAbtMT950	:=	.F.
	Private cDirNorma	:= cDir
	Private aParTSF		:=	aCfg
	Private aParNfse	:=	aNfse
	Private	lJobMT950	:=	lJob
	Private	lEofMT950	:=	.F.

	//������������������������������������������������������������������������Ŀ
	//�Calcula o Numero de Registros da Normativa a Processar                  �
	//��������������������������������������������������������������������������
	If !lTSF .And. !lNfse
		ProcRegua(Len(aNorma)+1)
		//������������������������������������������������������������������������Ŀ
		//�Processa a Normativa                                                    �
		//��������������������������������������������������������������������������
		aEval(aNorma,{|x| IncProc(x[16]),"",aadd(aBufferFim,RegNorma(x,@nHandle,@cTrab,cDir,cMaskVlr,lXml,aProcFil,@aTrab,lTSF,lQuebralin,lNfse,Len(aBufferFim)==Len(aNorma)-1))})
	Else
		//������������������������������������������������������������������������Ŀ
		//�Processa a Normativa                                                    �
		//��������������������������������������������������������������������������
		aEval(aNorma,{|x|,"",aadd(aBufferFim,RegNorma(x,@nHandle,@cTrab,cDir,cMaskVlr,lXml,aProcFil,@aTrab,lTSF,lQuebralin,lNfse))})
	Endif


	//������������������������������������������������������������������������Ŀ
	//�Encerra o arquivo binario                                               �
	//��������������������������������������������������������������������������
	FClose(nHandle)
	//������������������������������������������������������������������������Ŀ
	//�Efetua a gravacao no Cliente                                            �
	//��������������������������������������������������������������������������
	If !lTSF .And. !lNfse
		For nX := 1 to len(aNorma) 
			If len(aNorma[nX][8][1]) > 0 
				If !Empty(aNorma[nX][8][1][1])
					If (aNorma[nX][11][1])	//Se for para gerar registro no spool
						If (nPosSC:=aScan(aTrab,{|ax| AllTrim(aX[2])==AllTrim(aNorma[nX][8][1][1])}))>0
							aAdd (aArqSpool, AllTrim(aTrab[nPosSC,1]))
						EndIf
					EndIf
					lApaga := .F.
				EndIf
			EndIf	
		Next nX	
	
		For nX := 1 To Len(aBufferFim)
			If aBufferFim[nX]<>Nil .And. (Empty(aBufferFim[nX]) .Or. (!"T"$SubStr (aBufferFim[nX], 1, 1) .And. !"B"$SubStr (aBufferFim[nX], 1, 1)))
				aDel(aBufferFim,nX)
				nExcluidos++
				nX := 0
			EndIf
		Next nX      
		aSize(aBufferFim,Len(aBufferFim)-nExcluidos)
    Endif
	If !Empty (aBufferFim)
		cTrabSC	:= CriaTrab(,.F.)+".TXT"
		If lTSF
			nHdle:= FCreate ("\FTP\SINTEGRA\"+cDir+Alltrim(cDest)+".TXT",0)	
		ElseIF lNfse
			If ( ValType(aNFSe[1][20]) <> "U" )
				nHdle:= FCreate (cDir+Alltrim(cDest)+If(aNFSe[1][20],".XML",".TXT"),0)
			Else
				nHdle:= FCreate (cDir+Alltrim(cDest)+".TXT",0)
			EndIf
		Else
			nHdle:= FCreate (cTrabSC, 0)       			
	    Endif
		For nIndBuf := 1 To Len(aBufferFim)
			If ("T"$SubStr (aBufferFim[nIndBuf], 1, 1))
				FWrite(nHdle, SubStr (aBufferFim[nIndBuf], 2)+ Iif(lQuebralin,Chr(13)+Chr(10),"") )
			EndIf
		Next nIndBuf
		FT_FUse (cTrab)
		FT_FGoTop ()
		Do While !FT_FEoF () 
		
			cBuffer := FT_FReadLn ()      
			
			/*Encontrou uma linha inteira.*/
			If ( Len(cBuffer) < 1023 )
		                  
				/*Grava linha.*/                     
				FWrite(nHdle, cBuffer+Iif(lQuebralin,Chr(13)+Chr(10),""))     
			
			/*Encontrou um trecho maior ou igual a 1023k.*/
			Else                          			
			    /*Guarda todos os trechos da linha.*/
				cBuffer	:= ""               
			    
				/*Procura o final da linha.*/
				While .T.  					
					/*Verifica se encontrou o final da linha para gravar.*/				          					
					If ( Len(FT_fReadLn()) < 1023 )     					
						cBuffer += FT_fReadLn()           
						
						/*Grava a linha inteira no arquivo de destino.*/
						FWrite(nHdle, cBuffer+Iif(lQuebralin,Chr(13)+Chr(10),""))
						Exit 					
					Else   					
						cBuffer += FT_fReadLn()
						Ft_fSkip()					
					EndIf  					
				End	   
							
			EndIf		
			//
			FT_FSkip ()
		EndDo
		For nIndBuf := 1 To Len(aBufferFim)
			If ("B"$SubStr (aBufferFim[nIndBuf], 1, 1))
				FWrite(nHdle, SubStr (aBufferFim[nIndBuf], 2)+Iif(lQuebralin,Chr(13)+Chr(10),""))
			EndIf
		Next nIndBuf

		FT_FUse ()
		FClose (nHdle)
		
		//���������������������������������������������������������������������������������� �
		//�A partir do momento que estah variavel "lExitPFil" passou a ter conteudo .T.,    �
		//�   nao utilizo a funcionalidade de criacao de arquivos em pastas distintas, gero �
		//�   um unico arquivo que terah em seu conteudo todas as filiais consolidadas.     �
		//���������������������������������������������������������������������������������� �
		If Type("lExitPFil")=="L" .And. lExitPFil
			For nPriFil := 1 to Len(aFilsCalc)
				If aFilsCalc[nPriFil][1]
					cPriFil	:= aFilsCalc[nPriFil][2]
					Exit
				EndIf
			Next
			If At(cPriFil+"\",cDir)>0 
		 		cDir :=	Left(cDir,At(cPriFil+"\",cDir)-1)
		 	EndIf
	 	EndIf
	 		
		If !lTSF .And. !lNfse               
			aAdd(aArqSpool,cTrabSC)
		Endif
		FErase (cDir+cDest)                     
		If lHtml
			FRename(cTrabSC,cDest)
			&(cFunc+'("'+cDest+'")')
		Else
			__CopyFIle(cTrabSC,cDir+cDest)
		EndIF		
		If lNfse
			FErase(cTrab)
		EndIf			
	Else	
		If lApaga .And. !lAbtMT950
			//���������������������������������������������������������������������������������� �
			//�A partir do momento que estah variavel "lExitPFil" passou a ter conteudo .T.,    �
			//�   nao utilizo a funcionalidade de criacao de arquivos em pastas distintas, gero �
			//�   um unico arquivo que terah em seu conteudo todas as filiais consolidadas.     �
			//���������������������������������������������������������������������������������� �
			If Type("lExitPFil")=="L" .And. lExitPFil
				For nPriFil := 1 to Len(aFilsCalc)
					If aFilsCalc[nPriFil][1]
						cPriFil	:= aFilsCalc[nPriFil][2]
						Exit
					EndIf
				Next
				If At(cPriFil+"\",cDir)>0 
			 		cDir :=	Left(cDir,At(cPriFil+"\",cDir)-1)
			 	EndIf
		 	EndIf
		         
			If lTSF .Or. lNfse
				FErase (cDir+cDest)                     			
			Else		
				aAdd(aArqSpool,cTrab)
			Endif
			Ferase(cDir+cDest)  
			If lHtml
				FRename(cTrab,cDest)
				&(cFunc+'("'+cDest+'")')
			Else
				__CopyFIle(cTrab,cDir+cDest)
			EndIF		 
		Else
			If !lTSF .And. !lNfse .And. !lAbtMT950  .And. lImprime
				If ( cPaisLoc <> "MEX" ) .and. lExibeMsg
					If !lJob
						Aviso(STR0005,; //"Instrucoes Normativas"
							STR0006,; //"Esta instrucao normativa possui arquivos de destino especificos e portanto o parametro de destino nao foi respeitado!"
							{"OK"})
					EndIf
				Endif
			Endif
		EndIf	
	EndIf
Else                
	If lTSF .Or. lNfse
		cTSFHelp := "NORMAERRO2"+CHR(13)+CHR(10)
	Else	
		Help(" ",1,"NORMAERRO2")
	Endif
EndIf
If !lTSF .And. !lNfse
	If (lImprime) .And. !(lAbtMt950) .And. !lJob
		ImpSpool (cNorma, cDest, cDir, aArqSpool,aTrab)
	EndIf   
Endif
//
If !Empty (cMdb)
	If (File (cDir+cMdb))
		FErase (cDir+cMdb)
	EndIf
	WaitRun ("TxtToMdb "+cDir+cDest+" "+cDir+cMdb+" -ver=4", SW_HIDE)
EndIf
If lTSF    
	If Len(aParTSF)>0       
		aParTSF[1][17]+=cTSFHelp
	Endif	
Endif       
If lNfse
	If Len(aParNfse)>0       
		aParNfse[1][15]+=cTSFHelp
	Endif	
Endif       
Return(.T.)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �RegNorma  � Autor �Eduardo Riera          � Data �17.07.1999���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Processa um registro de Instrucao Normativa                 ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpA1: Registro da Norma                                    ���
���          �ExpN1: Handle do Arquivo a Ser Gravado                      ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function RegNormaA(aReg,nHandle,cTrab,cDir,cMaskVlr,lXml,aProcFil,aTrab,lTSF,lQuebralin,lNfse,lFim)

Local aArea		:= GetArea()
Local aArea1	:= {}
Local aArea2	:= {}
Local aArea3	:= {}
Local aAlias	:= aReg[1]
Local aPre	 	:= aReg[2]
Local aPreReg	:= aReg[3]
Local aPos		:= aReg[4]
Local aPosReg   := aReg[5]
Local aStru		:= aReg[6]
Local aConteudo := aReg[7]
Local aArq		:= aReg[8]
Local aContReg	:= aReg[9]
Local aINI      := aReg[10]
Local aDelimit	:= aReg[12]
Local aConsolidado := aReg[13]
Local aChv		:= aReg[14]
Local aOrd		:= aReg[15]
Local cFilDe		:=	""
Local cFilAte		:=	""
Local cChaveCons	:=	""
Local cCmpGrvCon	:=	""
Local aArqNew		:=	{}
Local uConteudo
Local cBuffer		:= ""
Local nCntFor		:= 0
Local bError
Local lContinua 	:= Len(aStru) > 0
Local nNivel    	:= 0
Local cDelimit  	:= ""
Local aAreaSm0	 	:= {}
Local cBufferFim 	:= ""
Local aChvNivel		:= {.F., .F., .F.}
Local aSkipChv		:=	{.F., .F., .F.}
Local lPosiciona	:= .F. 
Local aAreaPos		:= {}				// N�o � necess�rio declarar aqui, uso somente quando chamado pelo MATA940
Default lTSF 		:= .F.
Default lXml 		:= .F.                                               
Default aProcFil	:= Iif(lTSF,.F.,Iif(lNfse,.F.,{.F.,cFilAnt}))
Default aTrab		:=	{}
Default lFim		:= .F.

If !lTSF .And. !lNfse
	aAreaSm0:= SM0->(GetArea ())

	//lAbtMt950 - Aborta a rotina
	If (lAbtMT950) 
	    RestArea(aAreaSm0)
		Return (cBufferFim)
	EndIf

	//-- Define se suprime ultima linha em branco no final do arquivo para atender validador da prefeitura. Exemplo Osasco.
	If lEofMT950 .And. lFim
		lQuebralin := .F.
	EndIf
	
	If aAlias[1] <> "XXX"
		dbSelectArea(aAlias[1])
	EndIf
	
	aArea1 := GetArea()   
	//��������������������������������������������������������������Ŀ
	//�Posiciona o cFilAnt sempre na filial que esta sendo processada�
	//�atraves da selecao do aFisCalc.                               �
	//����������������������������������������������������������������
	If aProcFil[1]
		cFilAnt := aProcFil[2]
	Endif
	cFilDe		:=	&(aConsolidado[1][1])	//Filial de passado pelo INI
	cFilAte		:=	&(aConsolidado[1][2])	//Filial ate passado pelo INI
	cChaveCons	:=	aConsolidado[1][3]
	cCmpGrvCon	:=	aConsolidado[1][4]                       
	If Empty (cFilDe) .And. Empty (cFilAte)
		cFilDe		:=	cFilAnt
		cFilAte		:=	cFilAnt
	EndIf
	If !lTSF .And. !lNfse .And. (cFilDe#cFilAte)
		TrbConso (1, 1, aStru, cChaveCons, @aArqNew)
	EndIf
	DbSelectArea("SM0")                    
	SM0->(DbGoTop())
	SM0->(DbSeek (cEmpAnt+cFilDe, .T.))
Else
	//lAbtMt950 - Aborta a rotina
	If (lAbtMT950) 
		Return (cBufferFim)
	EndIf
	If !"XXX"$aAlias[1]
		dbSelectArea(aAlias[1])
	EndIf
	aArea1 := GetArea()   
EndIf

aCodLido	:=	{}
Do While lTSF .Or. lNfse .Or. (SM0->(!Eof()) .And. FWGrpCompany()+FWCodFil()<=cEmpAnt+cFilAte)
	If !lTSF .And. !lNfse
		cFilAnt	:=	FWCodFil()
	Endif	
	If !"XXX"$aAlias[1]
		dbSelectArea(aAlias[1])
	EndIf
	//������������������������������������������������������������������������Ŀ
	//�Efetua o Pre-Processamento                                              �
	//��������������������������������������������������������������������������
	aEval(aPre[1],{|x| &(x) })
	If !"XXX"$aAlias[1]
		
		dbSelectArea(aAlias[1])
		
		
		aChvNivel[1] := ( Len(aChv)>=1 .And. !Empty(aChv[1]) )
		While ( !Eof() ) .And. lContinua .And. Iif (aChvNivel[1], &(aChv[1]), .T.)
			cBuffer := ""
			aSkipChv	:=	{.T., .F., .F.}	//Controle para execucao do skip de cada nivel, este controle eh utilizado para quando a IN estah usando a clausula CHV.
			If (sfVldPReg (@aPreReg[1], @nHandle, lQuebralin))
				cDelimit	:=	AllTrim (aDelimit[1])
				cBuffer		+=	""
				//
				//�����������������������������������������������������������������������������������������������������������������������������������������������������������������������Ŀ
				//�Ha casos em que o delimitador eh so considerado no meio, ou so no inicio e fim, ou so no meio e fim, portanto foi criado a seguinte regra:                             �
				//�A clausula (DEL) no INI devera ser criada na seguinte estrutura:                                                                                                       �
				//�Ex: (DEL)|IMF, onde | eh o delimitador, I eh para gerar no incio de cada linha, M eh para gerar entre os campos de cada linha e F eh para gerar no final de cada linha.�
				//�Algumas formas de se utilizar:                                                                                                                                         �
				//�(DEL)|MF                                                                                                                                                               �
				//�(DEL)|M                                                                                                                                                                �
				//�(DEL)|IMF                                                                                                                                                              �
				//�(DEL)|IF                                                                                                                                                               �
				//�������������������������������������������������������������������������������������������������������������������������������������������������������������������������
				If !lTSF .And. !lNfse .And. (cFilDe#cFilAte)//Somente para o Nivel 1, inicialmente resolver o caso do MANAD
					ConsoFil (aArqNew, cChaveCons, 1, aStru, aConteudo, cCmpGrvCon)
					DbSelectArea (aAlias[1])
					(aAlias[1])->(DbSkip ())
					Loop
				EndIf

				If (Len (cDelimit)>1)
					If ("I"$SubStr (cDelimit, 2))
						cBuffer	+=	SubStr (cDelimit, 1, 1)
					EndIf
				EndIf

				For nCntFor := 1 To Len(aStru[1])
					bError := ErrorBlock({|e| Help(" ",1,"NORMAERRO3",,aAlias[1]+"->"+aStru[1][nCntFor][1]+"|"+aConteudo[1][nCntFor],3,1) })
					
					BEGIN SEQUENCE

				       uConteudo := &(aConteudo[1][nCntFor])
				       
   				       //Criado a exce��o pois o layout SEFINSC este campo deve ser do tamanho de 4000.
   				       //layout do ini s� aceita 999, o correto seria refazer a rotina que gera este arquivo magn�tico.
				       If ALLTRIM(MV_PAR03)=="SEFINSC" .And. AllTrim(aStru[1][nCntFor][1])=="NFEMIREC"
				       	aStru[1][nCntFor][3]:=4000
						EndIf

						Do Case
						Case ( aStru[1][nCntFor][2] == "N" )

							If ( uConteudo == Nil )
								uConteudo := 0
							EndIf

							If Empty (cMaskVlr) .Or. (aStru[1][nCntFor][4])==0
								uConteudo := NoRound(uConteudo*(10**(aStru[1][nCntFor][4])),aStru[1][nCntFor][4])
								//
								If (!Empty (aDelimit[1]))
									cBuffer += Iif (Empty (AllTrim (Str (uConteudo,aStru[1][nCntFor][3]))), "", AllTrim (Str (uConteudo,aStru[1][nCntFor][3])))
								Else
									cBuffer += StrZero(uConteudo,aStru[1][nCntFor][3])									
								EndIf
							Else
								cBuffer += AllTrim (Transform (uConteudo, cMaskVlr))
							EndIf

						Case ( aStru[1][nCntFor][2] == "D" )

							If ( uConteudo == Nil )
								uConteudo := dDataBase
							EndIf
							cBuffer += PadR(Dtos(uConteudo),aStru[1][nCntFor][3])

						Case ( aStru[1][nCntFor][2] == "C" )

							If ( uConteudo == Nil )
								uConteudo := ""
							EndIf

							If (!Empty (aDelimit[1]))
								cBuffer += AllTrim(uConteudo)
							Else   
								If !lXML .And. aStru[1][nCntFor][3]<>0
									cBuffer += PadR(uConteudo,aStru[1][nCntFor][3])
								Else                                                
									cBuffer += uConteudo
								EndIf
							EndIf

						EndCase

					END SEQUENCE
					ErrorBlock(bError)
					//�����������������������������������������������������������������������������������������������������������������������������������������������������������������������Ŀ
					//�Ha casos em que o delimitador eh so considerado no meio, ou so no inicio e fim, ou so no meio e fim, portanto foi criado a seguinte regra:                             �
					//�A clausula (DEL) no INI devera ser criada na seguinte estrutura:                                                                                                       �
					//�Ex: (DEL)|IMF, onde | eh o delimitador, I eh para gerar no incio de cada linha, M eh para gerar entre os campos de cada linha e F eh para gerar no final de cada linha.�
					//�Algumas formas de se utilizar:                                                                                                                                         �
					//�(DEL)|MF                                                                                                                                                               �
					//�(DEL)|M                                                                                                                                                                �
					//�(DEL)|IMF                                                                                                                                                              �
					//�(DEL)|IF                                                                                                                                                               �
					//�������������������������������������������������������������������������������������������������������������������������������������������������������������������������
					If (Len (cDelimit)>1)
						If (nCntFor==Len(aStru[1]))
							If ("F"$SubStr (cDelimit, 2))
								cBuffer	+=	SubStr (cDelimit, 1, 1)
							EndIf
						Else
							If ("M"$SubStr (cDelimit, 2))
								cBuffer	+=	SubStr (cDelimit, 1, 1)
							EndIf
						EndIf
					EndIf

				Next nCntFor

				//������������������������������������������������������������������������Ŀ
				//�Efetua a Gravacao da Linha                                              �
				//��������������������������������������������������������������������������
				If !Empty(cBuffer)
					FWrite(nHAndle,cBuffer+Iif(lQuebralin,Chr(13)+Chr(10),""))
					If !lTSF .And. !lNfse .And. ( Ferror()!=0 )
						Help(" ",1,"NORMAERRO4") 
					ElseIf ( Ferror()!=0 )
						cTSFHelp := "NORMAERRO4"+CHR(13)+CHR(10)						
					EndIf
				EndIf
				//�����������������������Ŀ
				//�Incrementa o contador  �
				//�������������������������
				aEval(aContReg[1],{|x| &(x) })     	
				//�����������������������������������������Ŀ
				//�FIM DO PRIMEIRO NIVEL                    �
				//�������������������������������������������
				If Len(aAlias)>=2
					If !"XXX"$aAlias[2]
						dbSelectArea(aAlias[2])
					EndIf
					aArea2 := GetArea()

					aEval(aPre[2],{|x| &(x) })

					If !"XXX"$aAlias[2]

						aChvNivel[2] := Len (aChv)>=2 .And. !Empty (aChv[2])
						While ( !Eof() )  .And. Iif (aChvNivel[2], &(aChv[2]), .T.)
							cBuffer := ""
							aSkipChv	:=	{.T., .T., .F.}	//Controle para execucao do skip de cada nivel, este controle eh utilizado para quando a IN estah usando a clausula CHV.
							If (sfVldPReg (@aPreReg[2], @nHandle, lQuebralin))

								cDelimit	:=	AllTrim (aDelimit[2])
								If (Len (cDelimit)>1)
									If ("I"$SubStr (cDelimit, 2))
										cBuffer	+=	SubStr (cDelimit, 1, 1)
									EndIf
								EndIf

								For nCntFor := 1 To Len(aStru[2])
									bError := ErrorBlock({|e| Help(" ",1,"NORMAERRO3",,aAlias[2]+"->"+aStru[2][nCntFor][1]+"|"+aConteudo[2][nCntFor],3,1) })
									BEGIN SEQUENCE
										uConteudo := &(aConteudo[2][nCntFor])
										Do Case
										Case ( aStru[2][nCntFor][2] == "N" )
											If ( uConteudo == Nil )
												uConteudo := 0
											EndIf

											If Empty (cMaskVlr) .Or. (aStru[2][nCntFor][4])==0
												uConteudo := NoRound(uConteudo*(10**(aStru[2][nCntFor][4])),aStru[2][nCntFor][4])
												If (!Empty (aDelimit[2]))
													cBuffer += Iif (Empty (AllTrim (Str (uConteudo,aStru[2][nCntFor][3]))), "", AllTrim (Str (uConteudo,aStru[2][nCntFor][3])))
												Else
													cBuffer += StrZero(uConteudo,aStru[2][nCntFor][3])
												EndIf
											Else
												cBuffer += AllTrim (Transform (uConteudo, cMaskVlr))
											EndIf

										Case ( aStru[2][nCntFor][2] == "D" )
											If ( uConteudo == Nil )
												uConteudo := dDataBase
											EndIf
											cBuffer += PadR(Dtos(uConteudo),aStru[2][nCntFor][3])
										Case ( aStru[2][nCntFor][2] == "C" )
											If ( uConteudo == Nil )
												uConteudo := ""
											EndIf
											If (!Empty (aDelimit[2]))
												cBuffer += AllTrim(uConteudo)
											Else   
												If !lXML .And. aStru[2][nCntFor][3]<>0
													cBuffer += PadR(uConteudo,aStru[2][nCntFor][3])
												Else                                                
													cBuffer += uConteudo
												Endif
											EndIf

										EndCase
									END SEQUENCE
									ErrorBlock(bError)

									If (Len (cDelimit)>1)
										If (nCntFor==Len(aStru[2]))
											If ("F"$SubStr (cDelimit, 2))
												cBuffer	+=	SubStr (cDelimit, 1, 1)
											EndIf
										Else
											If ("M"$SubStr (cDelimit, 2))
												cBuffer	+=	SubStr (cDelimit, 1, 1)
											EndIf
										EndIf
									EndIf

								Next nCntFor
								//������������������������������������������������������������������������Ŀ
								//�Efetua a Gravacao da Linha  nivel 2                                     �
								//��������������������������������������������������������������������������
								If !Empty(cBuffer)
									FWrite(nHAndle,cBuffer+Iif(lQuebralin,Chr(13)+Chr(10),""))
									If ( Ferror()!=0 )
										If lTSF .Or. lNfse
											cTSFHelp := "NORMAERRO4"+CHR(13)+CHR(10)																   
										Else                    
										   	Help(" ",1,"NORMAERRO4")
										Endif   
									EndIf
								EndIf
								//�����������������������Ŀ
								//�Incrementa o contador  �
								//�������������������������
								aEval(aContReg[2],{|x| &(x) })
							EndIf	
							//�������������������������������������Ŀ
							//�Inicio do nivel 3                    �
							//���������������������������������������
							If Len(aAlias)==3
								dbSelectArea(aAlias[3])
								aArea3 := GetArea()
								aEval(aPre[3],{|x| &(x) })

								aChvNivel[3] := Len (aChv)>=3 .And. !Empty (aChv[3])
								While ( !Eof() ) .And. Iif (aChvNivel[3], &(aChv[3]), .T.)
									cBuffer := ""
									aSkipChv	:=	{.T., .T., .T.}	//Controle para execucao do skip de cada nivel, este controle eh utilizado para quando a IN estah usando a clausula CHV.

									If (sfVldPReg (@aPreReg[3], @nHandle, lQuebralin))

										cDelimit	:=	AllTrim (aDelimit[3])
										If (Len (cDelimit)>1)
											If ("I"$SubStr (cDelimit, 2))
												cBuffer	+=	SubStr (cDelimit, 1, 1)
											EndIf
										EndIf

										For nCntFor := 1 To Len(aStru[3])
											bError := ErrorBlock({|e| Help(" ",1,"NORMAERRO3",,aAlias[3]+"->"+aStru[3][nCntFor][1]+"|"+aConteudo[3][nCntFor],3,1) })
											BEGIN SEQUENCE
												uConteudo := &(aConteudo[3][nCntFor])
												Do Case
												Case ( aStru[3][nCntFor][2] == "N" )
													If ( uConteudo == Nil )
														uConteudo := 0
													EndIf

													If Empty (cMaskVlr) .Or. (aStru[3][nCntFor][4])==0
														uConteudo := NoRound(uConteudo*(10**(aStru[3][nCntFor][4])),aStru[3][nCntFor][4])
														If (!Empty (aDelimit[3]))
															cBuffer += Iif (Empty (AllTrim (Str (uConteudo,aStru[3][nCntFor][3]))), "", AllTrim (Str (uConteudo,aStru[3][nCntFor][3])))
														Else
															cBuffer += StrZero(uConteudo,aStru[3][nCntFor][3])
														EndIf
													Else
														cBuffer += AllTrim (Transform (uConteudo, cMaskVlr))
													EndIf

												Case ( aStru[3][nCntFor][2] == "D" )
													If ( uConteudo == Nil )
														uConteudo := dDataBase
													EndIf
													cBuffer += PadR(Dtos(uConteudo),aStru[3][nCntFor][3])
												Case ( aStru[3][nCntFor][2] == "C" )
													If ( uConteudo == Nil )
														uConteudo := ""
													EndIf
													If (!Empty (aDelimit[3]))
														cBuffer += AllTrim(uConteudo)
													Else   
														If !lXML .And. aStru[3][nCntFor][3]<>0
															cBuffer += PadR(uConteudo,aStru[3][nCntFor][3])
														Else                                                
															cBuffer += uConteudo
														Endif
													EndIf
													
												EndCase
											END SEQUENCE
											ErrorBlock(bError)

											If (Len (cDelimit)>1)
												If (nCntFor==Len(aStru[3]))
													If ("F"$SubStr (cDelimit, 2))
														cBuffer	+=	SubStr (cDelimit, 1, 1)
													EndIf
												Else
													If ("M"$SubStr (cDelimit, 2))
														cBuffer	+=	SubStr (cDelimit, 1, 1)
													EndIf
												EndIf
											EndIf

										Next nCntFor
										//������������������������������������������������������������������������Ŀ
										//�Efetua a Gravacao da Linha  nivel 3                                     �
										//��������������������������������������������������������������������������
										If !Empty(cBuffer)
											FWrite(nHAndle,cBuffer+Iif(lQuebralin,Chr(13)+Chr(10),""))
											If ( Ferror()!=0 )
												If lTSF .Or. lNfse
													cTSFHelp := "NORMAERRO4"+CHR(13)+CHR(10)						
												Else	
													Help(" ",1,"NORMAERRO4")
												Endif
											EndIf
										EndIf
										//�����������������������Ŀ
										//�Incrementa o contador  �
										//�������������������������
										aEval(aContReg[3],{|x| &(x) })
									EndIf	
									aEval(aPosReg[3],{|x| &(x) })
									dbSelectArea(aAlias[3])
									dbSkip()
								EndDo
								//����������������������������������������������Ŀ
								//�Efetua o Pos-Processamento do nivel 3         �
								//������������������������������������������������
								aEval(aPos[3],{|x| &(x) })
								//����������������������������������������������Ŀ
								//�Efetua o INI-Processamento do nivel 3         �
								//������������������������������������������������
								aEval(aINI[3],{|x| ProcIni(x,@nHAndle,@cTrab,cDir,cMaskVlr,lXml,aProcFil,lTSF,lQuebralin,@aTrab,lNfse) })
								//��������������������������������������������������������������������������������������Ŀ
								//�Esta condicao se deve quando estiver utilizando a clausula (CHV), pois nao devo       �
								//�   retornar a Area salva antes do while, pois quando estiver utilizando esta clausula �
								//�   e sair do while jah estarah posicionado no proximo registro que deverah ser pro-   �
								//�   cessado novamente desde o nivel anterior, ou seja, neste caso, nivel 2.            �
								//����������������������������������������������������������������������������������������
								If !aChvNivel[3]
									RestArea(aArea3)
								EndIf
							EndIf
							//�����������������������Ŀ
							//�Fim do nivel 3         �
							//�������������������������
							If Len(aArq)>2
								If Len(aArq[3]) >= 1 .And. !Empty(aArq[3][1])
									//������������������������������������Ŀ
									//�Fecha e efetua a gravacao por bloco �		
									//��������������������������������������
									FClose(nHAndle)		
									// Caso seja necessario utilizar alguma informacao lancada em tempo de execucao no nome do arquivo, sera necessario gravar em um _aTotal
									If ("_ATOTAL["$Upper(aArq[3][1]))
										aArq[3][1]	:=	&(aArq[3][1])
									EndIf
									Ferase(cDir+aArq[3][1])
									__CopyFIle(cTrab,cDir+aArq[3][1])
									Aadd(aTrab,{cTrab,aArq[3][1]})
									cTrab	:= CriaTrab(,.F.)+".TXT"
									nHAndle  := FCreate(cTrab,0)
								EndIf						   	
							EndIf
							aEval(aPosReg[2],{|x| &(x) })
							dbSelectArea(aAlias[2])
							//�������������������������������������������������������������������������������������������Ŀ
							//�Tratamento para quando estiver utilizando a clausula (CHV) (condicao para o while).        �
							//�OBS: Nao precisarei dar SKIP novamente quando sair do terceiro NIVEL que tenha             �
							//�         o controle pela clausula (CHV), pois jah estara no proximo registro e nao deverah �
							//�         dar o SKIP novamente e sim voltar e processar o registro atual desde o nivel ante-�
							//�         rior, ou seja, neste caso o nivel 2                                               �
							//�OBS 2: A condicao abaixo determina NAO serah dado SKIP quando possuir a clausula CHV no    �
							//�         bloco em execucao, quando o alias do nivel 2 for igual ao alias do nivel 3 e quan-�
							//�         estiver executado o while do nivel 3, onde jah foi executado o SKIP e a tabela jah�
							//�         jah saiu do while com SKIP.                                                       �
							//���������������������������������������������������������������������������������������������
							If !(aChvNivel[3] .And. Len (aAlias)>=3 .And. aAlias[2]==aAlias[3] .And. aSkipChv[3])
								dbSkip()
							EndIf
						EndDo
					Else
						cBuffer := ""
						If (sfVldPReg(@aPreReg[2], @nHandle, lQuebralin))

							cDelimit	:=	AllTrim (aDelimit[2])
							If (Len (cDelimit)>1)
								If ("I"$SubStr (cDelimit, 2))
									cBuffer	+=	SubStr (cDelimit, 1, 1)
								EndIf
							EndIf				
							For nCntFor := 1 To Len(aStru[2])
								bError := ErrorBlock({|e| Help(" ",1,"NORMAERRO3",,aAlias[2]+"->"+aStru[2][nCntFor][2]+"|"+aConteudo[2][nCntFor],3,1) })
								BEGIN SEQUENCE			
									uConteudo := &(aConteudo[2][nCntFor])			
									Do Case
									Case ( aStru[2][nCntFor][2] == "N" )					
										If ( uConteudo == Nil )
											uConteudo := 0
										EndIf

										If Empty (cMaskVlr) .Or. (aStru[2][nCntFor][4])==0
											uConteudo := NoRound(uConteudo*(10**(aStru[2][nCntFor][4])),aStru[2][nCntFor][4])
											If (!Empty (aDelimit[2]))
												cBuffer += Iif (Empty (AllTrim (Str (uConteudo,aStru[2][nCntFor][3]))), "", AllTrim (Str (uConteudo,aStru[2][nCntFor][3])))
											Else
												cBuffer += StrZero(uConteudo,aStru[2][nCntFor][3])
											EndIf
										Else
											cBuffer += AllTrim (Transform (uConteudo, cMaskVlr))
										EndIf

									Case ( aStru[2][nCntFor][2] == "D" )
										If ( uConteudo == Nil )
											uConteudo := dDataBase
										EndIf
										cBuffer += PadR(Dtos(uConteudo),aStru[2][nCntFor][3])
									Case ( aStru[2][nCntFor][2] == "C" )
										If ( uConteudo == Nil )
											uConteudo := ""
										EndIf
										If (!Empty (aDelimit[2])) .Or. Empty(uConteudo)
											cBuffer += AllTrim (uConteudo)
										Else
											cBuffer += PadR(uConteudo,aStru[2][nCntFor][3])
										EndIf
									EndCase
								END SEQUENCE
								ErrorBlock(bError)

								If (Len(cDelimit)>1)
									If (nCntFor==Len(aStru[2]))
										If ("F"$SubStr (cDelimit, 2))
											cBuffer	+=	SubStr (cDelimit, 1, 1)
										EndIf
									Else
										If ("M"$SubStr (cDelimit, 2))
											cBuffer	+=	SubStr (cDelimit, 1, 1)
										EndIf
									EndIf
								EndIf

							Next nCntFor
							//������������������������������������������������������������������������Ŀ
							//�Efetua a Gravacao da Linha                                              �
							//��������������������������������������������������������������������������
							If !Empty(cBuffer)
								If ("TOP"$aOrd[2])
									cBufferFim += "T"+cBuffer
								ElseIf ("BOT"$aOrd[2])
									cBufferFim += "B"+cBuffer
								Else                  
									FWrite(nHAndle,cBuffer+Iif(lQuebralin,Chr(13)+Chr(10),""))
									If ( Ferror()!=0 )
										If lTSF .OR. lNfse
											cTSFHelp := "NORMAERRO4"+CHR(13)+CHR(10)						
										Else	
											Help(" ",1,"NORMAERRO4")
										Endif
									EndIf
								EndIf
							EndIf
							aEval(aPosReg[2],{|x| &(x) })
							//�����������������������Ŀ
							//�Incrementa o contador  �
							//�������������������������
							aEval(aContReg[2],{|x| &(x) })     			
						EndIf					
					EndIf
					//����������������������������������������������Ŀ
					//�Efetua o Pos-Processamento do nivel 2         �
					//������������������������������������������������
					aEval(aPos[2],{|x| &(x) })
					//����������������������������������������������Ŀ
					//�Efetua o INI-Processamento do nivel 2         �
					//������������������������������������������������
					aEval(aINI[2],{|x| ProcIni(x,@nHAndle,@cTrab,cDir,cMaskVlr,lXml,aProcFil,lTSF,lQuebralin,@aTrab,lNfse) })
					//��������������������������������������������������������������������������������������Ŀ
					//�Esta condicao se deve quando estiver utilizando a clausula (CHV), pois nao devo       �
					//�   retornar a Area salva antes do while, pois quando estiver utilizando esta clausula �
					//�   e sair do while jah estarah posicionado no proximo registro que deverah ser pro-   �
					//�   cessado novamente desde o nivel anterior, ou seja, neste caso, nivel 1.            �
					//����������������������������������������������������������������������������������������
					If !(aChvNivel[2])
						RestArea(aArea2)
					EndIf
				EndIf
				//�����������������������Ŀ
				//�Fim do nivel 2         �
				//�������������������������
				If Len(aArq)>=2
					If Len(aArq[2]) >= 1 .And. !Empty(aArq[2][1])
						//������������������������������������Ŀ
						//�Fecha e efetua a gravacao por bloco �
						//��������������������������������������
						FClose(nHAndle)
						If ("_ATOTAL["$Upper(aArq[2][1]))
							aArq[2][1]	:=	&(aArq[2][1])
						EndIf		
						Ferase(cDir+aArq[2][1])
						__CopyFIle(cTrab,cDir+aArq[2][1])
						Aadd(aTrab,{cTrab,aArq[2][1]})
						cTrab	:= CriaTrab(,.F.)+".TXT"
						nHAndle  := FCreate(cTrab,0)
					EndIf				   	
				EndIf
				aEval(aPosReg[1],{|x| &(x) })	
			EndIf

			dbSelectArea(aAlias[1])
			//�������������������������������������������������������������������������������������������Ŀ
			//�Tratamento para quando estiver utilizando a clausula (CHV) (condicao para o while).        �
			//�OBS: Nao precisarei dar SKIP novamente quando sair do terceiro/segundo NIVEL que tenha     �
			//�         o controle pela clausula (CHV), pois jah estarah no proximo registro e nao deverah�
			//�         dar o SKIP novamente e sim voltar e processar o registro atual desde o nivel ante-�
			//�         rior, ou seja, neste caso o nivel 1                                               �
			//�OBS 2: A condicao abaixo determina NAO serah dado SKIP quando possuir a clausula CHV no    �
			//�         bloco em execucao, quando o alias do nivel 1 for igual ao alias do nivel 2 e quan-�
			//�         estiver executado o while do nivel 2, onde jah foi executado o SKIP e a tabela jah�
			//�         jah saiu do while com SKIP.                                                       �
			//���������������������������������������������������������������������������������������������
			If !(aChvNivel[2] .And. Len (aAlias)>=2 .And. aAlias[1]==aAlias[2] .And. aSkipChv[2])
				dbSkip()
			EndIf
		EndDo
	Else
		cBuffer := ""
		If (sfVldPReg(@aPreReg[1], @nHandle, lQuebralin))

			cDelimit	:=	AllTrim (aDelimit[1])
			If (Len (cDelimit)>1)
				If ("I"$SubStr (cDelimit, 2))
					cBuffer	+=	SubStr (cDelimit, 1, 1)
				EndIf
			EndIf

			For nCntFor := 1 To Len(aStru[1])
				bError := ErrorBlock({|e| Help(" ",1,"NORMAERRO3",,aAlias[1]+"->"+aStru[1][nCntFor][1]+"|"+aConteudo[1][nCntFor],3,1) })
				BEGIN SEQUENCE			
					uConteudo := &(aConteudo[1][nCntFor])			
					Do Case
					Case ( aStru[1][nCntFor][2] == "N" )					
						If ( uConteudo == Nil )
							uConteudo := 0
						EndIf

						If Empty (cMaskVlr) .Or. (aStru[1][nCntFor][4])==0
							uConteudo := NoRound(uConteudo*(10**(aStru[1][nCntFor][4])),aStru[1][nCntFor][4])
							If (!Empty (aDelimit[1]))
								cBuffer += Iif (Empty (AllTrim (Str (uConteudo,aStru[1][nCntFor][3]))), "", AllTrim (Str (uConteudo,aStru[1][nCntFor][3])))
							Else
								cBuffer += StrZero(uConteudo,aStru[1][nCntFor][3])
							EndIf
						Else
							cBuffer += AllTrim (Transform (uConteudo, cMaskVlr))
						EndIf

					Case ( aStru[1][nCntFor][2] == "D" )
						If ( uConteudo == Nil )
							uConteudo := dDataBase
						EndIf
						cBuffer += PadR(Dtos(uConteudo),aStru[1][nCntFor][3])
					Case ( aStru[1][nCntFor][2] == "C" )
						If ( uConteudo == Nil )
							uConteudo := ""
						EndIf
						
						If (!Empty (aDelimit[1]))
							cBuffer += AllTrim (uConteudo)
						Else
							If !lXML .And. aStru[1][nCntFor][3]<>0
								cBuffer += PadR(uConteudo,aStru[1][nCntFor][3])
							Else                                                
								cBuffer += uConteudo
							Endif
						EndIf
					EndCase
				END SEQUENCE
				ErrorBlock(bError)

				If (Len(cDelimit)>1)
					If (nCntFor==Len(aStru[1]))
						If ("F"$SubStr (cDelimit, 2))
							cBuffer	+=	SubStr (cDelimit, 1, 1)
						EndIf
					Else
						If ("M"$SubStr (cDelimit, 2))
							cBuffer	+=	SubStr (cDelimit, 1, 1)
						EndIf
					EndIf
				EndIf

			Next nCntFor
			//������������������������������������������������������������������������Ŀ
			//�Efetua a Gravacao da Linha                                              �
			//��������������������������������������������������������������������������
			If !Empty(cBuffer)
				If ("TOP"$aOrd[1])
					cBufferFim += "T"+cBuffer
				ElseIf ("BOT"$aOrd[1])
					cBufferFim += "B"+cBuffer
				Else
					FWrite(nHAndle,cBuffer+Iif(lQuebralin,Chr(13)+Chr(10),""))
					If ( Ferror()!=0 )
						If lTSF .OR. lNfse
							cTSFHelp := "NORMAERRO4"+CHR(13)+CHR(10)						
						Else	
							Help(" ",1,"NORMAERRO4")
						Endif
					EndIf
				EndIf
			EndIf
			aEval(aPosReg[1],{|x| &(x) })
			//�����������������������Ŀ
			//�Incrementa o contador  �
			//�������������������������
			aEval(aContReg[1],{|x| &(x) })     			
		EndIf
	EndIf
	If lTSF .OR. lNfse
		Exit
	Else
		SM0->(DbSkip ())
	EndIf
EndDo

//������������������������������������������������������������������������Ŀ
//�Restaura a integridade da rotina                                        �
//��������������������������������������������������������������������������
If !lTSF .And. !lNfse
	RestArea(aAreaSm0)
    cFilAnt	:=	FWCodFil()
EndIf
//������������������������������������������������������������������������Ŀ
//�Efetua o Pos-Processamento                                              �
//��������������������������������������������������������������������������
aEval(aPos[1],{|x| &(x) })
//����������������������������������������������Ŀ
//�Efetua o INI-Processamento do nivel 1         �
//������������������������������������������������
aEval(aINI[1],{|x| ProcIni(x,@nHAndle,@cTrab,cDir,cMaskVlr,lXml,aProcFil,lTSF,lQuebralin,@aTrab,lNfse) })
//���������������������Ŀ
//�Restaura demais areas�
//�����������������������
RestArea(aArea1)
RestArea(aArea)

If !lTSF .And. !lNfse .And. (cFilDe#cFilAte)
	GeroConso (nHAndle, aDelimit, aStru, aArqNew, aAlias, aConteudo, aPosReg, aContReg, cMaskVlr, lQuebralin)
	TrbConso (2,,,, aArqNew)
EndIf   
If Len(aArq) >= 1
	If Len(aArq[1]) >= 1  .And. !Empty(aArq[1][1])
		//������������������������������������Ŀ
		//�Fecha e efetua a gravacao por bloco �
		//��������������������������������������
		FClose(nHAndle)
		// Caso seja necessario utilizar alguma informacao lancada em tempo de execucao no nome do arquivo, sera necessario gravar em um _aTotal
		If ("_ATOTAL["$Upper(aArq[1][1]))
			aArq[1][1]	:=	&(aArq[1][1])
		EndIf		
		Ferase(cDir+aArq[1][1])
		__CopyFile(cTrab,cDir+aArq[1][1])
		Aadd(aTrab,{cTrab,aArq[1][1]})
		cTrab	:= CriaTrab(,.F.)+".TXT"
		nHAndle  := FCreate(cTrab,0)
	EndIf	
EndIf
Return(cBufferFim)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcion   �ProcIni   � Autor � Eduardo Jose Zanardo   � Data �03/05/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Processa a Clausula INI                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/


Static Function ProcIni(cIniName,nHAndle,cTrab,cDir,cMaskVlr,lXml,aProcFil,lTSF,lQuebralin,aTrab,lNfse)
Local aNorma := {}

Default aProcFil := {.F.,cFilAnt}
Default  aTrab	 :=	{}

If ( !Empty(cIniName) )
	aNorma := ReadNorma(cIniName)                                          
	aEval(aNorma,{|x| RegNorma(x,@nHandle,@cTrab,cDir,cMaskVlr,lXml,aProcFil,@aTrab,lTSF,lQuebralin,lNfse)})
EndIf

Return(.T.)

/*/
�������������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������������Ŀ��
���Fun��o    �FsPrdInv      �  Autor  �     Eduardo Riera         � Data � 15/01/2003         ���
���������������������������������������������������������������������������������������������Ĵ��
���Descri��o � Calculo do saldo em estoque no ultimo inventario                               ���
���������������������������������������������������������������������������������������������Ĵ��
���Parametro �ExpC1: Codigo do produto                                                        ���
���          �ExpL2: Indica se o saldo em/de terceiro deve ser por CNPJ                       ���
���          �ExpD3: Indica a data do ultimo fechamento de estoque                            ���
���          �ExpA4: Array de par�metros do produto.				                          ���
���          �ExpL5: Valida a existencia do produto em Estoque                                ���
���          �ExpA6: Array de informa��es do armazem DE: AT�: quando o par�metro 4 est� vazio ���
���������������������������������������������������������������������������������������������Ĵ��
���Retorno   �ExpA [.][1] Quantidade do Produto                             				  ���
���          �     [.][2] Valor do Produto                                  				  ���
���          �     [.][3] 1 - Nosso:2-De terceiros;3-Em terceiros            				  ���
���          �     [.][4] Tipo(C/F)+Codigo de Cliente/Fornecedor            				  ���
���������������������������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   					  ���
���������������������������������������������������������������������������������������������Ĵ��
�������������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������������
*/
User Function FsPrdInvA(cCodPro,lCliFor,dUltFec,aProd,lValidEst,aLocal,l88AltReg)

Local nX         := 0
Local nY         := 0
Local nTam       := 0
Local nTam2      := 0
Local aSaldo     := {}
Local aRetorno   := {}
Local aRetPE	 := {}
Local lQuery     := .F.
Local lProdTerc  := .T.
Local lProcEst   := .T.
Local cQuery     := ""
Local cAliasSB9  := "SB9"
Local cAlmoxIni	:= ""
Local cAlmoxFim	:= ""
Local cCond		:= ""
Local cOrderBy	:= ""
Local aArea      := GetArea()
Local nSldTesN3	    := SuperGetMV("MV_SDTESN3",.F.,0)
Local lSldTesN3 	:= nSldTesN3 <> 0

DEFAULT aProd    := {}
DEFAULT aLocal   := {}
DEFAULT lValidEst := .F.
Default l88AltReg	:= .F.
dIniFec := CTod("01/"+STRZERO(Month(dUltFec),2)+"/"+STRZERO(Year(dUltFec),4))
dUltFec := Iif(Empty(dUltFec),SuperGetMv("MV_ULMES"),dUltfec)

//Alimento as variaveis dos filtros colocados para o registro de inventario quando s�o passados
//Algumas rotinas nao passam esse array como parametro para fun��o FsPrdInv acima e por isso s� alimento
//as variaveis quando o parametro e diferente de vazio.
//������������������������������������������������������������������Ŀ
//�aProd[01] = Produto de                                            �
//�aProd[02] = Produto ate                                           �
//�aProd[03] = Armazem de                                            �
//�aProd[04] = Armazem ate                                           �
//�aProd[05] = Saldo Negativo                                        �
//�aProd[06] = Saldo Zerado                                          �
//�aProd[07] = Saldo Terceiros (Sim, Nao, de terceiros, em terceiros)�
//�aProd[08] = Custo Zerado                                          �
//�aProd[09] = Em processo                                           �
//�aProd[10] = Data de Fechamento                                    �
//�aProd[11] = MOD no Processo                                       �
//��������������������������������������������������������������������
If !Empty(aProd)
	cAlmoxIni := aProd[3]
	cAlmoxFim := aProd[4]
	lProdTerc := (aProd[7]<>2)
EndIf

dbSelectArea("SB9")
dbSetOrder(1)

#IFDEF TOP  
	If TcSrvType()<>"AS/400"
		lQuery := .T.
	Endif
#ENDIF

If lQuery
	If ExistBlock("MA950QRY")
		cAliasSB9 := "FSPRDINV"
		
		cQuery := ExecBlock("MA950QRY",.F.,.F.,{cQuery})  // adiciona campos na query
		
		cQuery += "ORDER BY "+SqlOrder(SB9->(IndexKey()))
		cQuery := ChangeQuery(cQuery)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSB9)
		TcSetField(cAliasSB9,"B9_DATA","D",8,0)
		TcSetField(cAliasSB9,"B9_QINI","N",TamSx3("B9_QINI")[1],TamSx3("B9_QINI")[2])
		TcSetField(cAliasSB9,"B9_VINI1","N",TamSx3("B9_VINI1")[1],TamSx3("B9_VINI1")[2])
	
	ElseIf AllTrim(MV_PAR03)<>"SCANC"    	
		MsSeek(xFilial("SB9")+cCodPro)
		
	Else
		cAliasSB9 := "FSPRDINV"
		
		cCond	:=	"%"
		If !Empty(aProd)
			cCond += "SB9.B9_LOCAL>='"+cAlmoxIni+"' AND "
			cCond += "SB9.B9_LOCAL<='"+cAlmoxFim+"' AND "
		EndIf
		cCond	+=	"%"
		
		cOrderBy	:=	"% "+SqlOrder(SB9->(IndexKey()))+" %"
    	
		nTam	:= TamSx3("B9_QINI")[1]
		nTam2	:= TamSx3("B9_QINI")[2]
    	
		BeginSql Alias cAliasSB9
			COLUMN B9_DATA AS DATE
			COLUMN B9_QINI AS NUMERIC(nTam,nTam2)
			COLUMN B9_VINI1 AS NUMERIC(nTam,nTam2)
       		
			SELECT SB9.B9_FILIAL, SB9.B9_COD, SB9.B9_LOCAL, SB9.B9_QINI, SB9.B9_VINI1, SB9.B9_DATA
				
			FROM %table:SB9% SB9
			WHERE  SB9.B9_FILIAL   = %xfilial:SB9%  		AND
			SB9.B9_COD		  = %Exp:cCodPro%			AND
			%Exp:cCond%
			SB9.B9_DATA  >= %Exp:DTOS(dIniFec)% 	AND
			SB9.B9_DATA  <= %Exp:DTOS(dUltFec)% 	AND
			SB9.%notDel%								AND
			SB9.B9_DATA IN (	SELECT MAX(B9_DATA) 
								FROM %table:SB9% SB9 
								WHERE  SB9.B9_FILIAL	= %xfilial:SB9%	AND
										SB9.B9_COD	= %Exp:cCodPro%		AND
										%Exp:cCond%
										SB9.B9_DATA  >= %Exp:DTOS(dIniFec)% 	AND
										SB9.B9_DATA  <= %Exp:DTOS(dUltFec)% 	AND
										SB9.%notDel%)
			ORDER BY
			%Exp:cOrderBy%
		EndSql
		
	EndIf
Else
	MsSeek(xFilial("SB9")+cCodPro)
Endif

While (!Eof() .And. IIf(lQuery .And. ExistBlock("MA950QRY"),.T.,(cAliasSB9)->B9_FILIAL == xFilial("SB9") .And.;
		(cAliasSB9)->B9_COD == cCodPro .And. Iif(!Empty(aProd),(cAliasSB9)->B9_LOCAL >= cAlmoxIni .And.;
		(cAliasSB9)->B9_LOCAL<=cAlmoxFim,.T.)))

	lProcEst	:=	.T.

	If (cAliasSB9)->B9_DATA == dUltFec
		If ExistBlock('MA950INV')
            aRetPE:= ExecBlock( 'MA950INV', .F., .F., {cAliasSB9}) // Implementa array conforme regra do cliente
            If ValType(aRetPE)<>'A'
                aRetPE := {(cAliasSB9)->B9_QINI,(cAliasSB9)->B9_VINI1}
            EndIf 
        Else
			aRetPE := {(cAliasSB9)->B9_QINI,(cAliasSB9)->B9_VINI1}
		EndIf

		If lProdTerc //Considera Terceiro
			If Empty(aProd)//Senao foi passado nenhum parametro considero tudo
				aRetorno := SaldoTerc(cCodPro,(cAliasSB9)->B9_LOCAL,"T",dUltFec,(cAliasSB9)->B9_LOCAL,lCliFor,,iif(lSldTesN3,.T.,.F.))//De terceiro
				If lCliFor
					For nX := 1 To Len(aRetorno)
						nY := aScan(aSaldo,{|x| x[3] == 2 .And. x[4]==aRetorno[nX][1]})
						If nY==0
							aadd(aSaldo,{aRetorno[nX][2],aRetorno[nX][3],2,aRetorno[nX][1]})
							nY	:=	Len(aSaldo)
						Else
							aSaldo[nY][1] += aRetorno[nX][2]
							aSaldo[nY][2] += aRetorno[nX][3]
							aSaldo[nY][3] := 2
							aSaldo[nY][4] := aRetorno[nX][1]
						EndIf
						lProcEst	:=	aSaldo[nY][1]<>0
					Next nX
				Else
					nY := aScan(aSaldo,{|x| x[3] == 2 })
					If nY == 0
						aadd(aSaldo,{aRetorno[1],aRetorno[2],2,""})
						nY	:=	Len(aSaldo)
					Else
						aSaldo[nY][1] += aRetorno[1]
						aSaldo[nY][2] += aRetorno[2]
					EndIf
					lProcEst	:=	aSaldo[nY][1]<>0
				EndIf
				
				aRetorno := SaldoTerc(cCodPro,(cAliasSB9)->B9_LOCAL,"D",dUltFec,(cAliasSB9)->B9_LOCAL,lCliFor,,iif(lSldTesN3,.T.,.F.)) //Em terceiro
				If lCliFor
					For nX := 1 To Len(aRetorno)
						nY := aScan(aSaldo,{|x| x[3] == 3 .And. x[4]==aRetorno[nX][1]})
						If nY==0
							aadd(aSaldo,{aRetorno[nX][2],aRetorno[nX][3],3,aRetorno[nX][1]})
							nY	:=	Len(aSaldo)
						Else
							aSaldo[nY][1] += aRetorno[nX][2]
							aSaldo[nY][2] += aRetorno[nX][3]
							aSaldo[nY][3] := 3
							aSaldo[nY][4] := aRetorno[nX][1]
						EndIf
						lProcEst	:=	aSaldo[nY][1]<>0
					Next nX
				Else
					nY := aScan(aSaldo,{|x| x[3] == 3 })
					If nY == 0
						aadd(aSaldo,{aRetorno[1],aRetorno[2],3,""})
						nY	:=	Len(aSaldo)
					Else
						aSaldo[nY][1] += aRetorno[1]
						aSaldo[nY][2] += aRetorno[2]
					EndIf
					lProcEst	:=	aSaldo[nY][1]<>0
				EndIf
			Else
				If aProd[7]==1 .OR. aProd[7]==3
					aRetorno := SaldoTerc(cCodPro,(cAliasSB9)->B9_LOCAL,"T",dUltFec,(cAliasSB9)->B9_LOCAL,lCliFor,,iif(lSldTesN3,.T.,.F.)) //De terceiro
					If lCliFor
						For nX := 1 To Len(aRetorno)
							nY := aScan(aSaldo,{|x| x[3] == 2 .And. x[4]==aRetorno[nX][1]})
							If nY==0
								aadd(aSaldo,{aRetorno[nX][2],aRetorno[nX][3],2,aRetorno[nX][1]})
					  			nY	:=	Len(aSaldo)
							Else
								aSaldo[nY][1] += aRetorno[nX][2]
								aSaldo[nY][2] += aRetorno[nX][3]
								aSaldo[nY][3] := 2
								aSaldo[nY][4] := aRetorno[nX][1]
							EndIf
							lProcEst	:=	aSaldo[nY][1]<>0
						Next nX
					Else
						nY := aScan(aSaldo,{|x| x[3] == 2 })
						If nY == 0
							aadd(aSaldo,{aRetorno[1],aRetorno[2],2,""})
							nY	:=	Len(aSaldo)
						Else
							aSaldo[nY][1] += aRetorno[1]
							aSaldo[nY][2] += aRetorno[2]
						EndIf
						lProcEst	:=	aSaldo[nY][1]<>0
					EndIf
				EndIf
				If aProd[7]==1 .OR. aProd[7]==4
					aRetorno := SaldoTerc(cCodPro,(cAliasSB9)->B9_LOCAL,"D",dUltFec,(cAliasSB9)->B9_LOCAL,lCliFor,,iif(lSldTesN3,.T.,.F.)) //Em terceiro
					If lCliFor
						For nX := 1 To Len(aRetorno)
							nY := aScan(aSaldo,{|x| x[3] == 3 .And. x[4]==aRetorno[nX][1]})
							If nY==0
								aadd(aSaldo,{aRetorno[nX][2],aRetorno[nX][3],3,aRetorno[nX][1]})
								nY	:=	Len(aSaldo)
							Else
								aSaldo[nY][1] += aRetorno[nX][2]
								aSaldo[nY][2] += aRetorno[nX][3]
								aSaldo[nY][3] := 3
								aSaldo[nY][4] := aRetorno[nX][1]
							EndIf
							lProcEst	:=	aSaldo[nY][1]<>0
						Next nX
					Else
						nY := aScan(aSaldo,{|x| x[3] == 3 })
						If nY == 0
							aadd(aSaldo,{aRetorno[1],aRetorno[2],3,""})
							nY	:=	Len(aSaldo)
						Else
							aSaldo[nY][1] += aRetorno[1]
							aSaldo[nY][2] += aRetorno[2]
						EndIf
						lProcEst	:=	aSaldo[nY][1]<>0
					EndIf
				EndIf
			EndIf
		EndIf
		
		//If lProcEst		
			nY := aScan(aSaldo,{|x| x[3] == 1 .And. x[4]==""})
			If Len(aRetPE)>=2
				If nY==0
					aadd(aSaldo,{aRetPE[1],aRetPE[2],1,""})
				Else
					aSaldo[nY][1] += aRetPE[1]
					aSaldo[nY][2] += aRetPE[2]
					aSaldo[nY][3] := 1
					aSaldo[nY][4] := ""
				EndIf
			EndIf
		//EndIf	
	EndIf
	dbSelectArea(cAliasSB9)
	dbSkip()
EndDo
If lQuery
	dbSelectArea(cAliasSB9)
	dbCloseArea()
	dbSelectArea("SB9")
EndIf

//Se Valido a Existencia do produto em Estoque e o mesmo n�o � encontrado Retorno o Saldo vazio
//Senao retorno o Saldo com zero.
If !lValidEst
	If Empty(aSaldo)
		aSaldo := {{0,0,1,""},{0,0,2,""},{0,0,3,""}}
	EndIf
EndIf
		
RestArea(aArea)
Return(aSaldo)

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �FsEstInv  � Autor � Eduardo Riera         � Data �15/01/2003  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Calculo do saldo em estoque no ultimo inventario          	���
���������������������������������������������������������������������������Ĵ��
���Parametro �ExpA1: [1] Alias do Arquivo                                   ���
���          �       [2] Nome do arquivo fisico                             ���
���          �ExpN2: [1] Para Inicializacao                                 ���
���          �       [2] Para finalizacao                                   ���
���          �ExpL3: Indica se o saldo em/de terceiro deve ser por CNPJ     ���
���          �ExpL4: Indica se os produtos sem saldo devem ser registrados  ���
���          �ExpD5: Data de fechamento do estoque a ser considerada        ���
���          �ExpL6: Indica se a codifica��o deve ser feita por NCM         ���
���          �ExpL19: Indica se o Recno fara parte do NCM                   ���
���          �        Ex: Sintegra sim, Cotepe35 n�o                        ���
���������������������������������������������������������������������������Ĵ��
���Retorno   �Arquivo no formato:                                           ���
���          �     CODIGO  C 15   Codigo do Produto                         ���
���          �     UM      C 02   Unidade de Medida                         ���
���          �     SITUACA C 01   1-Proprio;2=Em Terceiro;3=De Terceiro     ���
���          �     QUANT   N 19 3 Quantidade                                ���
���          �     CUSTO   N 19 3 Custo Total                               ���
���          �     CNPJ    C 14 0 CNPJ  (Ver parametro ExpL3)               ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   	���
���������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     	���
���������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                   	���
���������������������������������������������������������������������������Ĵ��
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
User Function FsEstInvA( aAlias, nTipo, lCliFor, lMovimen, dUltFec, lNCM, lST, lSelB5, cFiltraB5,; 
				   aNFsProc, aProcCod, cFiltraB1, aProd, aProcesso, aFiliais, lSelFil,;
				   cFilDe, cFilAte, lAddRecno, lUsaBZ, aLocal, l88AltReg )

Local aCampos   := {}
Local aSaldo    := {}
Local aTam		:= {}
Local cAliasSB1 := "SB1"
Local cQuery    := ""
Local cCNPJ     := ""
Local cInsc 	:= ""
Local cUf	  	:= ""
Local lQuery    := .F.
Local lCodPro   := .F.
Local nX        := 0
Local cMvEstado := GetMv("MV_ESTADO")
Local cAliasNCM := ""
Local cArqNCM   := ""
Local cNome		:= ""
Local cCodNome	:= ""
Local aUltMov	:= {}
Local cCodInv	:= GetNewPar("MV_CODINV","")
Local lA950PRD	:= Existblock("A950PRD")
Local aICMS		:= {}
Local c88Ind	:= ""
Local cProdIni  := ""
Local cProdFim  := ""
Local lProdNeg  := .F.
Local lProdZera := .F.
Local lCustZero := .F.
Local lProcesso := .F.
Local nProc		:= 0
Local cAliasProc:= ""    
Local nQtdProc 	:= 0
Local nCustoProc:= 0
Local aAreaSM0  := SM0->(GetArea())
Local nQuantInvent := 0 
Local nCustoInvent := 0 
Local nPosic       := 0

#IFDEF TOP
	Local aStru     := {}
#ELSE
	Local c88Chave	:= ""
	Local c88Filtro	:= ""
	Local cIndSB6   := ""
	Local cChave    := ""
#ENDIF

Local lRgEspSt	:= GetNewPar("MV_RGESPST",.F.)
Local lUsaSFT	:= AliasInDic("SFT") .And. SFT->(FieldPos("FT_RGESPST")) > 0
Local aNCM		:= {}
Local cCorte88 	:= GetNewPar("MV_88CORTE","")
Local nCorte88 	:= Iif(!Empty(cCorte88),SB1->(FieldPos(cCorte88)),0)
Local dDTSTMG	:= GetNewPar("MV_DTSTMG",cTod("//"))
Local cIndR74   := ''
Local cIndR74a  := ''
Local cChave	:= ''
Local cChavea	:= ''
Local l74Item	:= GetNewPar("MV_74ITEM",.F.)
Local cCampoSB1	:= ""
Local cSelB5	:= ""
Local cCond	:= ""
Local cCond2	:= ""
Local cOrderBy	:= ""

DEFAULT lCliFor 	:= .F.
DEFAULT lMovimen	:= .T.
DEFAULT dUltFec 	:= SuperGetMV("MV_ULMES")
DEFAULT lNCM    	:= .F.
DEFAULT lST			:= .F.
DEFAULT lSelB5		:= .F.
DEFAULT cFiltraB5	:= ""
DEFAULT cFiltraB1	:= ""
DEFAULT	aNFsProc	:= {}
DEFAULT	aProcCod	:= {}
DEFAULT aProd 	    := {}  
DEFAULT aProcesso	:= {}
DEFAULT aFiliais    := {}
DEFAULT lSelFil     := .F.
DEFAULT cFilDe      := cFilAnt
DEFAULT cFilAte     := cFilAnt 
DEFAULT lAddRecno := .T.  //Define se o recno fara parte do NCM
DEFAULT lUsaBZ 	:= .F.
DEFAULT l88AltReg	:= .F. //Irei iniciar como falso para manter o legado, que � sempre calcular restitui��o somente se houver sa�da no per�odo

//Alimento as variaveis dos filtros colocados para o registro de inventario quando s�o passados
//Algumas rotinas nao passam esse array como parametro para fun��o FSESTINV acima e por isso s� alimento
//as variaveis quando o parametro e diferente de vazio.
//������������������������������������������������������������������Ŀ
//�aProd[01] = Produto de                                            �
//�aProd[02] = Produto ate                                           �
//�aProd[03] = Armazem de                                            �
//�aProd[04] = Armazem ate                                           �
//�aProd[05] = Saldo Negativo                                        �
//�aProd[06] = Saldo Zerado                                          �
//�aProd[07] = Saldo Terceiros (Sim, Nao, de terceiros, em terceiros)�
//�aProd[08] = Custo Zerado                                          �
//�aProd[09] = Em processo                                           �
//�aProd[10] = Data de Fechamento                                    �
//�aProd[11] = MOD no Processo                                       �
//��������������������������������������������������������������������
If !Empty(aProd)
	cProdIni  := aProd[1]
	cProdFim  := aProd[2]
	lProdNeg  := (aProd[5]==1)
	lProdZera := (aProd[6]==1)
	lCustZero := (aProd[8]==1)             
	If Len(aProd) >= 11
		lProcesso := (aProd[9]==1)
	Endif 
EndIf

If !Empty(cFiltraB5) 
	lSelB5 := .T.
Endif                                                                           

If nTipo==1
	//�������������������������������������������Ŀ
	//�Verifica como as filiais serao processadas:�
	//�- apenas a filial                          �
	//�- filial de/ate                            �
	//�- filiais selecionadas                     �
	//���������������������������������������������
	If Empty(cFilDe) .And. Empty(cFilAte)
		cFilDe	:= cFilAte := cFilAnt
	EndIf
	
	If lSelFil
		If aScan( aFiliais, {|x| x[1] == .T.} ) > 0
			cFilDe 	:= aFiliais[01][02]
			cFilAte	:= aFiliais[Len(aFiliais)][02]
		Else
			cFilDe	:=	cFilAte	:=	cFilAnt
		EndIf
	EndIf
	
	//�������������������Ŀ
	//�Processo as Filiais�
	//���������������������
	DbSelectArea ("SM0")
	SM0->(DbSeek (cEmpAnt+cFilDe,.T.))
	Do While !SM0->(Eof ()) .And. (FWGrpCompany()==cEmpAnt) .And. (FWCodFil()<=cFilAte)

		//����������������������������������������������������������������������������������������������Ŀ
		//�Se foram selecionadas as filiais, identifica se a filial posicionada esta selecionada no array�
		//������������������������������������������������������������������������������������������������
		If lSelFil
			nPosFil := aScan(aFiliais,{|x| Alltrim(x[2]) == Alltrim(FWCodFil())})
			If nPosFil <> 0 .And. !(aFiliais[nPosFil,1])
				SM0->(dbSkip())
  	        	Loop
  			Endif
		EndIf

		//--Troco para filial que foi
		//--selecionada na janela de selecao
		//--de filiais
		cFilAnt	:= FWCodFil()

		//��������������������������������������������������������Ŀ
		//�Verifica os saldos em processo quando a rotina solicitar�
		//����������������������������������������������������������
		If lProcesso
			cAliasProc := FsProcesso(aProd,dUltFec,@aNCM,@aProcesso)	
		Endif
		
		If lST
			#IFNDEF TOP                         
				dbSelectArea("SD1")
				c88Ind		:=	CriaTrab(NIL,.F.)
				c88Chave	:=	"D1_NFORI+D1_SERIORI+D1_ITEMORI"
				c88Filtro	:=	"D1_FILIAL == '" + xFilial("SD1") + "' .And. "
				If !lRgEspSt
					c88Filtro	+=	"D1_TIPO $ 'P/I/C' .And. D1_ICMSRET > 0 .And. Dtos(D1_DTDIGIT) < '" + Dtos(dUltFec) + "'"
				Else
					c88Filtro	+=	"D1_TIPO $ 'P/I/C' .And. Dtos(D1_DTDIGIT) < '" + Dtos(dUltFec) + "'"
				Endif
				IndRegua("SD1",c88Ind,c88Chave,,c88Filtro,Nil,.F.)
				dbClearIndex()	
				RetIndex("SD1")
				dbSetIndex(c88Ind+OrdBagExt())
				dbSetOrder(1)
			#ENDIF
		Endif
	
		PRIVATE nIndSb6 := 0
		#IFNDEF TOP
			dbSelectArea("SB6")
			cIndSB6 := CriaTrab(Nil,.F.)
			cChave := "B6_FILIAL+B6_PRODUTO+B6_LOCAL+B6_TIPO+DTOS(B6_DTDIGIT)"
			cQuery := 'B6_FILIAL="'+xFilial("SB6")+'" .And. DtoS(B6_DTDIGIT)<="'+Dtos(dUltFec)+'"'
			IndRegua("SB6",cIndSB6,cChave,,cQuery,Nil,.F.)
			nIndSB6:=RetIndex("SB6")
			dbSetIndex(cIndSB6+OrdBagExt())
			dbSetOrder(nIndSB6 + 1)
			dbGoTop()
		#ENDIF
		CriaTrb88(aAlias,l74Item,aCampos)
		
		#IFDEF TOP
			cAliasSB1 := "FSESTINV"
			lQuery    := .T.
			
			cCampoSB1	:=	"%"
			cCampoSB1	+= " SB1.B1_FILIAL, SB1.B1_TIPO, SB1.B1_COD, SB1.B1_DESC, SB1.B1_UM, SB1.B1_POSIPI, SB1.B1_PICMENT, SB1.B1_PICM, SB1.B1_CLASFIS, SB1.B1_CODBAR, SB1.R_E_C_N_O_ "
			
			//���������������������������������������������������������Ŀ
			//�Verifica a data de corte para consideracao do Sintegra-MG�
			//�����������������������������������������������������������
			If nCorte88 > 0
				cCampoSB1 += ", SB1." + Alltrim(cCorte88)
			EndIf
			
			cCampoSB1	+=	"%"
			
			cTabela := "%"
			cTabela += RetSqlName("SB1")+" SB1 "
			
			cCond := "%"   
			If lSelB5
				cTabela += " , "+RetSqlName("SB5")+" SB5 "
				cCond += "	SB5.B5_FILIAL = '"+xFilial("SB5")+"' AND "
				cCond += "	SB5.B5_COD = SB1.B1_COD AND "
				cCond += "	SB5.D_E_L_E_T_=' ' AND "               
			Endif
			cCond += "%"
			
			cTabela += "%"
			
			cCond2	:=	"%"
			If !Empty(cFiltraB5)
				cCond2 += cFiltraB5
			Endif
			cCond2	+=	"%"
		
			cOrderBy	:=	"% "+SqlOrder(SB1->(IndexKey()))+" %"
			
			BeginSql Alias cAliasSB1
       		
			SELECT  
					%Exp:cCampoSB1%				
			FROM	%Exp:cTabela%
			WHERE  SB1.B1_FILIAL   = %xfilial:SB1%  		AND
					%Exp:cCond%
					SB1.%notDel%
					%Exp:cCond2%
			ORDER BY
					%Exp:cOrderBy%
			EndSql
	
		#ELSE
			MsSeek(xFilial("SB1"))
		#ENDIF
		While !Eof() .And. (cAliasSB1)->B1_FILIAL == xFilial("SB1")
	
			If !Empty(cFiltraB1) .And. !(cAliasSB1)->B1_TIPO $cFiltraB1 
				(cAliasSB1)->(dbSkip())
				Loop
			EndIf
			If !Empty(aProd)   
				If !((cAliasSB1)->B1_COD>=cProdIni .And. (cAliasSB1)->B1_COD<=cProdFim)
					(cAliasSB1)->(dbSkip())
					Loop
				EndIf 
			EndIf	
			//��������������������������������������������������������������Ŀ
			//�Verifica se devera ser considerado o SB5 na geracao do estoque�
			//����������������������������������������������������������������
			If lSelB5 .And. !lQuery
				SB5->(dbSetOrder(1))
				If !(SB5->(dbSeek(xFilial("SB5")+(cAliasSB1)->B1_COD)))
					(cAliasSB1)->(dbSkip())
					Loop
				Endif
				If !Empty(cFiltraB5)
					If !(&cFiltraB5)
						(cAliasSB1)->(dbSkip())        						
						Loop
					Endif
				Endif
			Endif
			If !lCodPro .And. Len(AllTrim((cAliasSB1)->B1_COD))>=15 .And. !lA950PRD .And. AllTrim(MV_PAR03)<>"SCANC" .And. AllTrim(MV_PAR03)<>"NORMA242" 
				lCodPro := .T.
			EndIf
	
			If lST
				//��������������������������������������������������������������Ŀ
				//�Verifica a data de corte pelo produto ou mantem pelo parametro�
				//����������������������������������������������������������������
				If nCorte88 > 0 .And. !Empty((cAliasSB1)->&(cCorte88))
					dDtStMG := (cAliasSB1)->&(cCorte88)
				Endif
				
				//��������������������������������������������������������������������Ŀ
				//�Apenas processa o saldo dos produtos que estiverem dentro           �
				//�da data de corte estipulada, no caso do processamento do Sintegra MG�
				//����������������������������������������������������������������������
				If dDtStMG > dUltFec
					(cAliasSB1)->(dbSkip())
					Loop
				Endif
			Endif
			//Verifica se devera ser considerado o SBZ			
			If lUsaBZ
				SBZ->(dbSetOrder(1))
				SBZ->(dbSeek(xFilial("SBZ")+(cAliasSB1)->B1_COD))
				lUsaBZ := SBZ->(FieldPos("BZ_CLASFIS")) > 0
			Endif
			aSaldo := FsPrdInv((cAliasSB1)->B1_COD,lCliFor,dUltFec,aProd,.T.,aLocal,l88AltReg)

	        //Se aSaldo retornar vazio � pq o produto nao existe no estoque e portanto nao sera considerado pois o Len de aSaldo retornar� 0 e n�o ir� incluir o produto
	        //Mas se o parametro lMoviment estiver como True devo considerar o produto como a rotina funcionava antes
	        If lMovimen
	        	If Empty(aSaldo)
					aSaldo := {{0,0,1,""},{0,0,2,""},{0,0,3,""}}
				EndIf
	        EndIf
	        
			For nX := 1 To Len(aSaldo)
				If aSaldo[nX][1]<>0 .Or. aSaldo[nX][3]==1
					If !Empty(aSaldo[nX][4])
						If SubStr(aSaldo[nX][4],1,1)=="C"
							dbSelectArea("SA1")
							dbSetOrder(1)
							MsSeek(xFilial("SA1")+SubStr(aSaldo[nX][4],2))
							cCNPJ 		:= SA1->A1_CGC
							cInsc 		:= SA1->A1_INSCR
							cUf	  		:= SA1->A1_EST
							cNome		:= SubStr(SA1->A1_NOME,1,40)
							cCodNome 	:= SA1->A1_COD
						Else
							dbSelectArea("SA2")
							dbSetOrder(1)
							MsSeek(xFilial("SA2")+SubStr(aSaldo[nX][4],2))
							cCNPJ		:= SA2->A2_CGC
							cInsc 		:= SA2->A2_INSCR
							cUf	  		:= SA2->A2_EST
							cNome 		:= SubStr(SA2->A2_NOME,1,40)
						cCodNome 	:= SA2->A2_COD
						EndIf
					Else
						cCNPJ := SM0->M0_CGC
						cINSC := SM0->M0_INSC
						cUf	  := cMvEstado
					EndIf

					//���������������������������������������������������������������Ŀ
					//�Busca no temporario o saldo em processo do produto - se existir�
					//�����������������������������������������������������������������
				    nQtdProc 	:= 0
				    nCustoProc 	:= 0
					If lProcesso  
					   (cAliasProc)->(dbSetOrder(2))
					   If (cAliasProc)->(dbSeek((cAliasSB1)->B1_COD))
						   nQtdProc 	:= (cAliasProc)->QUANTIDADE
						   nCustoProc 	:= (cAliasProc)->TOTAL
					   Endif
					Endif
				
					If lMovimen

						If !(aAlias[1])->(DbSeek((cAliasSB1)->B1_COD))
							RecLock(aAlias[1], .T. )
						Else
							RecLock(aAlias[1], .F. )
						EndIf
						
						(aAlias[1])->DESC_PRD := (cAliasSB1)->B1_DESC
						(aAlias[1])->CODIGO   := IIf(lA950PRD,Execblock("A950PRD",.F.,.F.,{cAliasSB1}),(cAliasSB1)->B1_COD)
						(aAlias[1])->CODPRD   := (cAliasSB1)->B1_COD
						(aAlias[1])->UM       := (cAliasSB1)->B1_UM
						(aAlias[1])->SITUACA  := StrZero(aSaldo[nX][3],1)
						(aAlias[1])->QUANT    += aSaldo[nX][1] + nQtdProc
						(aAlias[1])->CUSTO    += aSaldo[nX][2] + nCustoProc
						(aAlias[1])->CNPJ     := cCNPJ
						(aAlias[1])->INSCR    := cINSC
						(aAlias[1])->UF   	  := cUF
						If lQuery
							(aAlias[1])->NCM      := IIf(lAddRecno,ALLTRIM(STR((cAliasSB1)->R_E_C_N_O_)),'')+(cAliasSB1)->B1_POSIPI 
						Else
							(aAlias[1])->NCM      := IIf(lAddRecno,ALLTRIM(STR((cAliasSB1)->(RECNO()))),'')+(cAliasSB1)->B1_POSIPI
						EndIf
						(aAlias[1])->NOME  	  := cNome
						(aAlias[1])->CODNOME  := cCodNome
						(aAlias[1])->TIPO	  := (cAliasSB1)->B1_TIPO
						If At((cAliasSB1)->B1_TIPO+"=",cCodInv) > 0
							(aAlias[1])->CODINV := Substr(cCodInv,At((cAliasSB1)->B1_TIPO+"=",cCodInv)+3,1)
						Else
							(aAlias[1])->CODINV := "1"	//Mercadorias
						Endif
						//���������������������������������������������������������������������������������������Ŀ
						//�Verifica o valor do ICMS Subst. Tributaria da ultima entrada, de acordo com o parametro�
						//�Apenas para os produtos que possuem a aliquota do ICMS ST entrada em seu cadastro.     �
						//�����������������������������������������������������������������������������������������
						If lST .And. ((!lRgEspSt .And. (cAliasSB1)->B1_PICMENT > 0) .Or. lRgEspSt)
							//��������������������������������������������������������������0
							//�Somente verifica as ultimas entradas de composicao do estoque�
							//�se existirem movimentos de saida (processados pelo Mata940 - �
							//�funcao a94088MG).                                            �
							//��������������������������������������������������������������0
							nProc := aScan(aProcCod,{|x| x[1]==(aAlias[1])->CODPRD})
																					
							If nProc > 0 .And. aProcCod[nProc][3]
								aICMS := RetTotICMS((cAliasSB1)->B1_COD,dUltFec,aSaldo[nX][1],c88Ind,@aNFsProc,lRgEspSt,lUsaSFT,(cAliasSB1)->B1_PICMENT,dDtStMG)
								(aAlias[1])->VALICMS  += aICMS[1]	//ICMS Proprio
								(aAlias[1])->ICMSRET  += aICMS[2]	//ICMS ST
								(aAlias[1])->BASEST   += aICMS[3]
								(aAlias[1])->BASEICMS += aICMS[4]
							Endif
						Endif
						(aAlias[1])->CLASSFIS	:=	IIf(lUsaBZ,SBZ->BZ_CLASFIS,(cAliasSB1)->B1_CLASFIS)
						MsUnLock()
					Else
						If nX == 3 .And. Iif( Len(aProd)>0, aProd[07] == 1, .T. )     													
							nPosic := aScan(aSaldo,{|x| x[3] == 3 .And. x[1]<>0 .And. x[2]<>0})																			
							If nPosic == 0								
								nPosic := 2
							EndIf																								
							nQuantInvent := ((aSaldo[nX][1] - aSaldo[nPosic][1]) + nQtdProc)
							nCustoInvent := ((aSaldo[nX][2] - aSaldo[nPosic][2]) + nCustoProc)
						Else
							nQuantInvent := aSaldo[nX][1] + nQtdProc
							nCustoInvent := aSaldo[nX][2] + nCustoProc
						EndIf	
							
 						If (aSaldo[nX][1]>0 .And. aSaldo[nX][2]>0 .And. nQuantInvent>0 .And. nCustoInvent>0) .OR. (lProdNeg .And. aSaldo[nX][1]< 0)  .OR. (lProdZera .And. aSaldo[nX][1]==0) .OR. (lCustZero .And. aSaldo[nX][2]==0) .OR. (lProcesso .And. nQtdProc > 0)
                            
                            If !l74Item
  							   If !(aAlias[1])->(DbSeek((cAliasSB1)->B1_COD))
								   RecLock(aAlias[1], .T. )
							   Else
								   RecLock(aAlias[1], .F. )
							   EndIf
							Else   
  							   If !(aAlias[1])->(DbSeek((cAliasSB1)->B1_COD+StrZero(aSaldo[nX][3],1)+cCNPJ))
								   RecLock(aAlias[1], .T. )
							   Else
								   RecLock(aAlias[1], .F. )
							   EndIf
							Endif

							(aAlias[1])->DESC_PRD := (cAliasSB1)->B1_DESC
							(aAlias[1])->CODIGO   := IIf(lA950PRD,Execblock("A950PRD",.F.,.F.,{cAliasSB1}),(cAliasSB1)->B1_COD)
							(aAlias[1])->CODPRD   := (cAliasSB1)->B1_COD
							(aAlias[1])->UM       := (cAliasSB1)->B1_UM
							(aAlias[1])->SITUACA  := StrZero(aSaldo[nX][3],1)
							(aAlias[1])->QUANT    := nQuantInvent
							(aAlias[1])->CUSTO    := nCustoInvent
							(aAlias[1])->CNPJ     := cCNPJ
							(aAlias[1])->INSCR    := cINSC
							(aAlias[1])->UF       := cUF
							(aAlias[1])->CODNCM   := (cAliasSB1)->B1_POSIPI
							If lQuery
								(aAlias[1])->NCM  := IIf(lAddRecno,ALLTRIM(STR((cAliasSB1)->R_E_C_N_O_)),'')+(cAliasSB1)->B1_POSIPI 
							Else
								(aAlias[1])->NCM  := IIf(lAddRecno,ALLTRIM(STR((cAliasSB1)->(RECNO()))),'')+(cAliasSB1)->B1_POSIPI
							EndIf
							(aAlias[1])->NOME  	   := cNome
							(aAlias[1])->CODNOME  := cCodNome
							(aAlias[1])->TIPO     := (cAliasSB1)->B1_TIPO

							If At((cAliasSB1)->B1_TIPO+"=",cCodInv) > 0
								(aAlias[1])->CODINV := Substr(cCodInv,At((cAliasSB1)->B1_TIPO+"=",cCodInv)+3,1)
							Else
								(aAlias[1])->CODINV := "1"	//Mercadorias
							Endif

							//���������������������������������������������������������������������������������������Ŀ
							//�Verifica o valor do ICMS Subst. Tributaria da ultima entrada, de acordo com o parametro�
							//�Apenas para os produtos que possuem a aliquota do ICMS ST entrada em seu cadastro.     �
							//�����������������������������������������������������������������������������������������
							If lST .And. ((!lRgEspSt .And. (l88AltReg .OR. (cAliasSB1)->B1_PICMENT > 0)) .Or. lRgEspSt)   
								//��������������������������������������������������������������0
								//�Somente verifica as ultimas entradas de composicao do estoque�
								//�se existirem movimentos de saida (processados pelo Mata940 - �
								//�funcao a94088MG).                                            �
								//��������������������������������������������������������������0
								
								nProc := aScan(aProcCod,{|x| x[1]==(aAlias[1])->CODPRD})
																	
								IF l88AltReg
									IF SB5->(dbSeek(xFilial("SB5")+(cAliasSB1)->B1_COD)) .AND. SB5->B5_ALTTRIB == "1"
										IF nProc == 0
											//Adiciona aqui o produto que teve altera��o de tributa��o do ICMS ST
											//Aqui adiciona somente produtos com margem do ST zerada e com flag na B5 que 
											//teve altear��o de tributa��o
											aAdd(aProcCod,{(cAliasSB1)->B1_COD,(cAliasSB1)->B1_COD,.T.,0})																					
										Else
											//Altero para verdadeiro a terceira op��o para que seja o produto seja 
											//processado no ressarcimento do ICMS ST na hip�tese de mudan�a de regime do ST
											aProcCod[nProc][3]	:= .T.
										EndIF
									EndIF
								EndIF
															
								//Se l88AltReg for verdadeiro ir� calcular restitui��o sem que haja necessidade de ter
								//documento fiscal de sa�da ou entrada no per�odo							
								//Se l88AltReg for falso, ir� calcular restitui��o somente se houver documento de entrada
								//e sa�da no per�odo
								//Em ambos os casos ser�o consideradas as �ltimas ntoas de compra com ST
								//para fazer a m�dia ponderada da restitui��o
								If (nProc > 0 .And. aProcCod[nProc][3]) .OR. (l88AltReg .AND. SB5->B5_ALTTRIB == "1")
									aICMS := RetTotICMS((cAliasSB1)->B1_COD,dUltFec,aSaldo[nX][1],c88Ind,@aNFsProc,lRgEspSt,lUsaSFT,(cAliasSB1)->B1_PICMENT,dDtStMG,l88AltReg)
									(aAlias[1])->VALICMS  += aICMS[1]	//ICMS Proprio
									(aAlias[1])->ICMSRET  += aICMS[2]	//ICMS ST							
									(aAlias[1])->BASEST   += aICMS[3]   //Base ICMS ST
									(aAlias[1])->BASEICMS += aICMS[4]	//Base ICMS Proprio
								Endif
							Endif
							(aAlias[1])->CLASSFIS	:=	IIf(lUsaBZ,SBZ->BZ_CLASFIS,(cAliasSB1)->B1_CLASFIS)
							MsUnLock()
						Endif
					Endif
				EndIf
			Next nX
			dbSelectArea(cAliasSB1)
			dbSkip()
		EndDo

		If lQuery
			dbSelectArea(cAliasSB1)
			dbCloseArea()
			dbSelectArea("SB1")
		EndIf

		#IFNDEF TOP
			dbSelectArea("SB6")
			RetIndex("SB6")
			Ferase(cIndSB6+OrdBagExt())
		#ENDIF

		//������������������������������������������������������������������������Ŀ
		//�Verifica se os produtos devem ser aglutinados por NCM                   �
		//��������������������������������������������������������������������������
		If lNCM
			cAliasNCM := "RNCM" //GetNextAlias()

			If Select(cAliasNCM) <= 0
				cArqNCM   := CriaTrab(aCampos,.T.)
				dbUseArea(.T.,__LocalDrive,cArqNCM,cAliasNCM,.F.,.F.)
				If lCodPro
					IndRegua(cAliasNCM,cArqNCM,"NCM+SITUACA+CNPJ+INSCR",,,Nil,.F.)	//?Por NCM
				Else
					IndRegua(cAliasNCM,cArqNCM,"CODIGO+SITUACA+CNPJ+INSCR",,,Nil,.F.)	//Por codigo produto
				EndIf
			EndIf

			dbSelectArea(aAlias[1])
			dbGotop()
			While !Eof()      
			
				//������������������������������������������������������������Ŀ
				//�Busca no array de aglutinacao dos NCMs os saldos em processo�
				//��������������������������������������������������������������
			    nQtdProc 	:= 0
			    nCustoProc 	:= 0
				If lProcesso  
					nPosNCM := aScan(aNCM,{|x| x[1] == (aAlias[1])->NCM}) 
					If nPosNCM > 0
					    nQtdProc 	:= aNCM[nPosNCM][02]
					    nCustoProc 	:= aNCM[nPosNCM][03]
					Endif
				Endif
			
				dbSelectArea(cAliasNCM)
				If MsSeek(Iif (lCodPro, (aAlias[1])->NCM, (aAlias[1])->CODIGO)+(aAlias[1])->SITUACA+(aAlias[1])->CNPJ+(aAlias[1])->INSCR)
					RecLock(cAliasNCM,.F.)
				Else
					RecLock(cAliasNCM,.T.)
				EndIf
				(cAliasNCM)->DESC_PRD	:=	(aAlias[1])->DESC_PRD
				(cAliasNCM)->CODIGO 	:= Iif (lCodPro, (aAlias[1])->NCM, (aAlias[1])->CODIGO)
				(cAliasNCM)->CODPRD 	:= (aAlias[1])->CODPRD
				(cAliasNCM)->UM     	:= (aAlias[1])->UM
				(cAliasNCM)->SITUACA	:= (aAlias[1])->SITUACA
				(cAliasNCM)->QUANT  	+= (aAlias[1])->QUANT + nQtdProc
				(cAliasNCM)->CUSTO  	+= (aAlias[1])->CUSTO + nCustoProc
				(cAliasNCM)->CNPJ   	:= (aAlias[1])->CNPJ
				(cAliasNCM)->INSCR  	:= (aAlias[1])->INSCR
				(cAliasNCM)->UF   		:= (aAlias[1])->UF
				(cAliasNCM)->NCM   		:= (aAlias[1])->CODNCM
				(cAliasNCM)->NOME   	:= (aAlias[1])->NOME
				(cAliasNCM)->CODNOME	:= (aAlias[1])->CODNOME
				(cAliasNCM)->BASEST 	+= (aAlias[1])->BASEST
				(cAliasNCM)->VALST		+= (aAlias[1])->VALST
				(cAliasNCM)->ALIQST		:= (aAlias[1])->ALIQST
				(cAliasNCM)->TIPO		:= (aAlias[1])->TIPO
				(cAliasNCM)->VALICMS	+= (aAlias[1])->VALICMS	//ICMS Operacoes Proprias
				(cAliasNCM)->ICMSRET	+= (aAlias[1])->ICMSRET	//ICMS ST
				If At((aAlias[1])->TIPO+"=",cCodInv) > 0
					(cAliasNCM)->CODINV := Substr(cCodInv,At((aAlias[1])->TIPO+"=",cCodInv)+3,1)
				Else
					(cAliasNCM)->CODINV := "1"	//Mercadorias
				Endif
				(cAliasNCM)->CLASSFIS	:= (aAlias[1])->CLASSFIS
				MsUnLock()
				dbSelectArea(aAlias[1])
				dbSkip()
			EndDo

			dbSelectArea(aAlias[1])
			dbCloseArea()

			dbSelectArea(cAliasNCM)
			dbCloseArea()

			FErase(cAliasNCM+OrdBagExt())
			
			FErase(aAlias[2]+GetDbExtension())
			FErase(cIndR74+OrdBagExt())
			FErase(cIndR74a+OrdBagExt())

			aAlias[2] := cArqNCM
			dbUseArea(.T.,__LocalDrive,aAlias[2],aAlias[1],.F.,.F.)
			cIndR74 := CriaTrab(NIL,.F.)
			cChave	:= "CODPRD"
			IndRegua(aAlias[1],cIndR74,cChave)  
			cIndR74a := CriaTrab(NIL,.F.)
			cChavea	:= "CODPRD+SITUACA+CNPJ"
			IndRegua(aAlias[1],cIndR74a,cChavea)
			
			If AllTrim(aAlias[1]) == "R74" 
				cIndR74b := CriaTrab(NIL,.F.)
				cChaveb  := "CODIGO"
				IndRegua(aAlias[1],cIndR74b,cChaveb)			
			EndIf					

		EndIf
		If lST
			#IFNDEF TOP
				dbSelectArea("SD1")
				RetIndex("SD1")
				FErase(c88Ind+OrdBagExt())
			#ENDIF		
		Endif
		SM0->(DbSkip())
	End
	RestArea(aAreaSm0)
Else
	dbSelectArea(aAlias[1])
	dbCloseArea()
	FErase(aAlias[2]+GetDbExtension())
	//���������������������������������������������������������Ŀ
	//�Exclui temporario criado para gerar os saldos em processo�
	//�����������������������������������������������������������
	If Len(aProcesso) > 0
		dbSelectArea(aProcesso[2])
		dbCloseArea()
		FErase(aProcesso[1]+GetDbExtension())
	Endif               
	
	dbSelectArea("SM0")
EndIf
RestArea (aAreaSm0)
cFilAnt	:= FWCodFil()
Return(.T.)

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �FsQuery   � Autor � Eduardo Riera         � Data �16/01/2003  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Rotina de selecao de registros atraves de comandos SQL      	���
���������������������������������������������������������������������������Ĵ��
���Parametro �ExpA1: Array de controle                                    	���
���          �       [1] Alias da tabela principal                          ���
���          �       [2] Controle Interno ( ExpC )                          ���
���          �       [3] Novo alias                                    (TOP)���
���          �ExpN2: [1] Inicializacao                                    	���
���          �       [2] Finalizacao                                        ���
���          �ExpC3: Expressao SQL ( WHERE )                           (OPC)���
���          �ExpC4: Expressao ADVPL ( Filter )                        (OPC)���
���          �ExpC5: Expressao ADVPL ( Index  )                        (OPC)���
���������������������������������������������������������������������������Ĵ��
���Retorno   �ExpA [1] Quantidade do Produto                              	���
���          �     [2] Valor do Produto                                   	���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   	���
���������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     	���
���������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                   	���
���������������������������������������������������������������������������Ĵ��
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
User Function FsQueryA(aControle,nTipo,cWhere,cFilter,cKey, aIN, aJoin, cFields, cGroup, cFrom, lSelDel, aFilsCalc, lDesc)
#IFDEF TOP
	Local aStru  := {}
	Local nX     := 0
	Local cQuery := ""
	
	Local nVezFil	:= 0
	Local cFilOrig	:= cFilAnt
	Local cInQuery	:= ''
	Local cInFilter	:= ''
	Local lPriFil	:= .T.
	Local cFilVez	:= ''
	Local cNewStr	:= ''
	Default cWhere := ''
	Default cFilter := '' 
#ENDIF

//������������������������������������������������������������������������Ŀ
//�Selecao dos dados a serem filtrados                                     �
//��������������������������������������������������������������������������
#IFDEF TOP
If TcSrvType()<>"AS/400"
	DEFAULT aIn := {}
	DEFAULT aJoin := {}
	DEFAULT cFields	:= " * "
	DEFAULT cGroup	:= ""
	DEFAULT cFrom 	:= ""
	DEFAULT lSelDel	:= .F. //Seleciona linhas deletadas (IN08655)
	DEFAULT aFilsCalc	:= { }		// Tratamento multi-filiais para gest�o corporativa
	DEFAULT lDesc     := .F.

	If Len(aControle)==2
		aadd(aControle,aControle[1])
	EndIf

	If nTipo == 1
		// Tratamento a multi-filiais
		cWhere := Upper(cWhere)
		cFilter:= Upper(cFilter)
		If Len(aFilsCalc) > 0
			For nVezFil := 1 to Len(aFilsCalc)
				If !aFilsCalc[nVezFil][01]
					Loop
				Else
					cFilAnt		:= aFilsCalc[nVezFil][02]
					cFilVez		:= xFilial(aControle[1])
					cInQuery	:= IIf(lPriFil, "'", cInQuery+",'" )+ cFilVez +"'"
					cInFilter	:= IIf(lPriFil, "'", cInFilter+"/" )+ cFilVez
					lPriFil		:= .F.	
					If Empty(cFilVez)
						Exit
					EndIf			
				EndIf
			Next
			cInQuery	:= "("+ cInQuery + ")"
			cInFilter	:= cInFilter + "'"
			cFilAnt		:= cFilOrig
			cNewStr		:= cWhere
			While At('_FILIAL=',cNewStr) > 0
				// Posiciona na string _FILIAL=, tira o '=' e inclui o IN com todas as filiais selecionadas  
				cNewStr	:= Subs(cWhere, 1, At('_FILIAL=',cWhere)+6 )+" IN "+cInQuery
				// Pega a nova string e soma o conte�do da string antiga, eliminando o ='xxx' -> onde xxx � a string da filial �nica
				cNewStr	:= cNewStr + Subs(cWhere, At('_FILIAL=',cWhere) + 9 + Len(cFilAnt) + 1 )
				// 9 -> _FILIAL + '=' + caracter delimitador   
				// Len(cFilAnt) -> tamanho da string filial 
				// 1 -> caracter delimitador da string
				cWhere	:= cNewStr				
			EndDo
			
			cNewStr	:= cFilter
			While At('_FILIAL==',cNewStr) > 0
				// Posiciona na string _FILIAL==, tira o '==' e inclui o IN com todas as filiais selecionadas  
				cNewStr	:= Subs(cFilter, 1, At('_FILIAL==',cFilter)+6 )+" $ "+cInFilter
				// Pega a nova string e soma o conte�do da string antiga, eliminando o ='xxx' -> onde xxx � a string da filial �nica
				cNewStr	:= cNewStr + Subs(cFilter, At('_FILIAL==',cFilter) + 10 + Len(cFilAnt) + 1 )
				// 9 -> _FILIAL + '==' + caracter delimitador   
				// Len(cFilAnt) -> tamanho da string filial 
				// 1 -> caracter delimitador da string
				cFilter	:= cNewStr
			EndDo						
		EndIf
		cQuery := "SELECT" + cFields
		aStru  := (aControle[1])->(dbStruct())
		If Empty(cFrom)
			cQuery += " FROM "+RetSqlName(aControle[1])+" "
			If !Empty( aJoin )
				cQuery += "INNER JOIN "+RetSqlName(aJoin[1])+" "
				cQuery += "ON " + ajoin[2]
				If !"D_E_L_E_T_" $ aJoin[2]
					cQuery += " AND " + RetSqlName(aJoin[1])+".D_E_L_E_T_=' ' "
				EndIf
			EndIf
			cQuery += "WHERE "
			If !Empty(cWhere)
				cQuery += cWhere+" AND "
			EndIf

			If !Empty( aIN )
				cQuery += " " + aIn[1] + " IN " + aIn[2] + " AND "
			EndIf

			If lSelDel
				cQuery := Left(cQuery,Len(cQuery)-4)
			Else
				cQuery += RetSqlName(aControle[1])+".D_E_L_E_T_=' ' "
			Endif
		Else
			cQuery += "FROM "+cFrom
			If !Empty(cWhere)
				cQuery += " WHERE " + cWhere
				If !Empty( aIN )
					cQuery += " AND "+aIn[1]+" IN " +aIn[2]
				EndIf
			EndIf
		EndIf

		If !Empty(cGroup)
			cQuery += " GROUP BY "+cGroup+" "
		Endif

		If !Empty(cKey)
			cQuery += " ORDER BY "+SqlOrder(cKey)
			If lDesc
				cQuery += " DESC "
			EndIf
		EndIf

		cQuery := ChangeQuery(cQuery)

		If Select(aControle[3])<>0
			(aControle[3])->(dbCloseArea())
		EndIf

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),aControle[3])
		If !Empty(cFrom)
			aStru  := (aControle[3])->(dbStruct())
		EndIf
		For nX := 1 To Len(aStru)
			If aStru[nX][2] <> "C"
				TcSetField(aControle[3],aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
			EndIf
		Next nX
	Else
		dbSelectArea(aControle[3])
		dbCloseArea()
		dbSelectArea(aControle[1])
	EndIf
Else
#ENDIF
	If Len(aControle)==2
		aadd(aControle,aControle[1])
	EndIf
	If nTipo == 1
		If aControle[1] <> aControle[3]
			ChkFile(aControle[1],.F.,aControle[3])
		EndIf
		dbSelectArea(aControle[3])
		aControle[2] := CriaTrab(,.F.)
		Do Case
		Case !Empty(cKey) .And. !Empty(cFilter)
			IndRegua(aControle[3],aControle[2],cKey,,cFilter,Nil,.F.)
		Case !Empty(cKey)
			IndRegua(aControle[3],aControle[2],cKey,,,Nil,.F.)
		EndCase
	Else
		If aControle[1] <> aControle[3]
			dbSelectArea(aControle[3])
			dbCloseArea()
			dbSelectArea(aControle[1])
		Else
			RetIndex(aControle[1])
		EndIf
		FErase(aControle[2]+OrdBagExt())
	EndIf
#IFDEF TOP
EndIf
#ENDIF
Return(.T.)

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �FsDump    � Autor � Eduardo Riera         � Data �16/01/2003  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Rotina generica de DUMP de arquivo                          	���
���������������������������������������������������������������������������Ĵ��
���Parametro �ExpC1: Nome do arquivo de lay-out                           	���
���          �ExpN2: [1] Para parametros                                  	���
���          �       [2] Para impressao                                   	���
���          �ExpC3: Nome do arquivo magnetico de destino                 	���
���          �ExpC4: Diretorio de destino                                 	���
���������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      	���
���          �                                                            	���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   	���
���������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     	���
���������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                   	���
���������������������������������������������������������������������������Ĵ��
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
User Function FsDumpA(cLayOut,nTipo,cArquivo,cDir)

Local aArea   := GetArea()
Local Titulo  := "DUMP"
Local cDesc1  := "Este relatorio imprime a listagem de acompanhamento dos meios-magnetivos"
Local cDesc2  := ""
Local cDesc3  := ""
Local wnrel   := "DUMP"  // Nome do Arquivo utilizado no Spool
Local nomeprog:= "DUMP"  // nome do programa

Private Tamanho := "G" // P/M/G
Private Limite  := 220 // 80/132/220
Private lEnd    := .F.// Controle de cancelamento do relatorio
Private m_pag   := 1  // Contador de Paginas
Private nLastKey:= 0  // Controla o cancelamento da SetPrint e SetDefault
If nTipo == 1
	aReturn := { STR0005, 1,STR0006, 1, 2, 1, "",1 } //"Zebrado"###"Administracao"
	//[1] Reservado para Formulario
	//[2] Reservado para N� de Vias
	//[3] Destinatario
	//[4] Formato => 1-Comprimido 2-Normal
	//[5] Midia   => 1-Disco 2-Impressora
	//[6] Porta ou Arquivo 1-LPT1... 4-COM1...
	//[7] Expressao do Filtro
	//[8] Ordem a ser selecionada
	//[9]..[10]..[n] Campos a Processar (se houver)
	//������������������������������������������������������������������������Ŀ
	//�Envia para a SetPrinter                                                 �
	//��������������������������������������������������������������������������
	wnrel:=SetPrint("",wnrel,"",@Titulo,cDesc1,cDesc2,cDesc3,.F.,,.T.,Tamanho,,.F.)
Else
	SetDefault(aReturn,"")
	RptStatus({|lEnd| FsImpDet(cLayOut,cArquivo,cDir,@lEnd,wnrel,nomeprog,Titulo)},Titulo)
EndIf
RestArea(aArea)
Return(.T.)
/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �FsImpDet  � Autor � Eduardo Riera         � Data �16/01/2003  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Rotina generica de DUMP de arquivo - Impressao              	���
���������������������������������������������������������������������������Ĵ��
���Parametro �ExpL1: Controle de saida                                    	���
���          �ExpC2: Nome do arquivo magnetico de destino                 	���
���          �ExpC3: Diretorio de destino                                 	���
���          �ExpC4: Nome do arquivo de impressao                         	���
���          �ExpC5: Nome do programa de impressao                      	���
���          �ExpC6: Titulo do relatorio                                	���
���������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      	���
���          �                                                            	���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   	���
���������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     	���
���������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                   	���
���������������������������������������������������������������������������Ĵ��
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Static Function FsImpDet(cLayOut,cFisico,cDir,lEnd,wnrel,nomeprog,Titulo)

Local aCabec   := {}
Local aDumpP   := {}
Local aDumpU   := {}
Local cLinha   := ""
Local cComando := ""
Local nX       := 0
Local nY       := 0
Local nZ       := 0
Local Li       := 100

Private cArquivo := cFisico //Utilizado dentro do layout do dump

If File(cLayOut)
	//������������������������������������������������������������������������Ŀ
	//�Calcula o DUMP dos 30 primeiros e 30 ultimos registros                  �
	//��������������������������������������������������������������������������
	cDir := AllTrim(cDir)
	FT_FUse(cDir+cArquivo)
	FT_FGotop()
	While ( !FT_FEof() )
		cLinha   := SubStr(FT_FREADLN(),1,220)
		If Len(aDumpP) < 30
			aadd(aDumpP,cLinha)
		EndIf
		aadd(aDumpU,cLinha)
		If Len(aDumpU) > 30
			aDumpU := aDel(aDumpU,1)
			aDumpU := aSize(aDumpU,30)
		EndIf
		FT_FSkip()
	EndDo
	FT_FUse()

	//������������������������������������������������������������������������Ŀ
	//�Imprime a listagem de acompanhamento                                    �
	//��������������������������������������������������������������������������
	If Li > 60
		Li:=0
		@ 000,000 PSAY AvalImp(limite)
		For nY := 1 To Len(aCabec)
			@ Li,000 PSAY &(aCabec[nY])
			Li++
		Next nY
	EndIf
	FT_FUse(cLayOut)
	FT_FGotop()
	While ( !FT_FEof() )
		cLinha   := FT_FREADLN()
		nX       := At("]",cLinha)
		cComando := Upper(SubStr(cLinha,2,nX-2))
		Do Case
		Case cComando == "PSAY" .Or. cComando == "CABEC"
			If !Empty(SubStr(cLinha,nX+1))
				@ Li,000 PSAY &(SubStr(cLinha,nX+1))
			EndIf
			Li++
			If cComando == "CABEC"
				aadd(aCabec,SubStr(cLinha,nX+1))
			EndIf
		Case cComando == "DUMPP"
			For nY := 1 To Len(aDumpP)
				@ Li,000 PSAY aDumpP[nY]
				Li++
				If Li > 60
					Li:=0
					@ 000,000 PSAY AvalImp(limite)
					For nZ := 1 To Len(aCabec)
						@ Li,000 PSAY &(aCabec[nZ])
						Li++
					Next nZ
				EndIf
			Next nY
		Case cComando == "DUMPU"
			For nY := 1 To Len(aDumpU)
				@ Li,000 PSAY aDumpU[nY]
				Li++
				If Li > 60
					Li:=0
					@ 000,000 PSAY AvalImp(limite)
					For nZ := 1 To Len(aCabec)
						@ Li,000 PSAY &(aCabec[nZ])
						Li++
					Next nZ
				EndIf
			Next nY
		EndCase
		FT_FSkip()
	EndDo
	FT_FUSE()
	Set Device To Screen
	Set Printer To
	If ( aReturn[5] = 1 )
		dbCommitAll()
		OurSpool(wnrel)
	Endif
EndIf
MS_FLUSH()
Return(.T.)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �FisGetEnd � Autor �Nereu Humberto Jr      � Data �12.12.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Retorna a estrutura do endereco passado                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpA:  [1] Endereco                                         ���
���          �       [2] Numero                                           ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1: Texto do Endereco                                    ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function FisGetEndA(cEndereco, cUF)
Local nVirgula    := Rat(",",cEndereco)
Local cNumero     := ""
Local nNumero     := 0
Local lEndNfe     := If(FunName()=="SPEDNFE" .Or. IsInCallStack("FISA008"), .T., .F.) 
Local cEnderec    := ""
Local cCompl      := ""
Local cComplemen  := ""
Local lExterior   := .F.
Local cEndAlte    := ""
Local aNumStr     := {}
Local lTMS        := If(nModulo == 43, .T., .F.) 
Default cUF       := ""

If ExistBlock('FISATEND')
	cEndAlte := ExecBlock('FISATEND',.F.,.F.,{ cEndereco, cUF })
	If !Empty(cEndAlte)
		cEndereco := cEndAlte
	EndIf		
EndIf	
lExterior   := (cUF == "EX")

cNumero     := If(!lExterior, AllTrim(SubStr(cEndereco,nVirgula+1)), Left(cEndereco, nVirgula-1))
nNumero     := NoRound(Val(cNumero),3)
cCompl      := If(!lExterior, AllTrim(SubStr(cEndereco,nVirgula+1)), Left(cEndereco, nVirgula-1))
cComplemen  := ""

If lTMS 
	If nNumero != 0
		If !lExterior
			cEnderec := PadR(SubStr(cEndereco, 1, nVirgula-1), 50)
		Else
			cEnderec := PadR(LTrim(SubStr(cEndereco, nVirgula+1)), 50)
		EndIf
	Else
		cEnderec := PadR(cEndereco, 50)
	EndIf
ElseIf lEndNfe
	If nNumero != 0
		If !lExterior
			cEnderec := PadR(SubStr(cEndereco, 1, nVirgula-1), 60)
		Else
			cEnderec := PadR(LTrim(SubStr(cEndereco, nVirgula+1)), 60)
		EndIf
	Else
		cEnderec := PadR(cEndereco, 60)
	EndIf
Else
	If nNumero != 0
		If !lExterior
			cEnderec := PadR(SubStr(cEndereco,1,nVirgula-1),34)
		Else
			cEnderec := PadR(LTrim(SubStr(cEndereco, nVirgula+1)), 34)
		EndIf
	Else
		cEnderec := PadR(SubStr(cEndereco,1,nVirgula-1),34)
	EndIf
EndIf

//��������������������������������������������������������������Ŀ
//�Quando nao ha virgula no endereco procura-se o caracter branco�
//����������������������������������������������������������������
If ( nVirgula == 0 )
	nVirgula 	:= Rat(" ",AllTrim(cEndereco))
	cEnderec	:= RTrim(cEndereco)
	cCompl		:= ""	//NAO TEM COMO PEGAR O COMPLEMENTO, JAH QUE UTILIZO O ULTIMO ESPACO A DIREITO PARA SEPARAR O LOGRADOURO DO NUMERO.
	cNumero     := AllTrim(SubStr(cEndereco,nVirgula+1))
	cEnderec	:= Iif(Val(cNumero) > 0, AllTrim(SubStr(cEndereco,1,nVirgula)), cEndereco)
	aNumStr		:= RetNumStr(cNumero)
	If Len(aNumStr[1]) > 1
		cNumero := "S/N"
	EndIf
	nNumero		:= Val(cNumero)
	If lEndNfe == .F.
		lEnderec	:= PadR(IIf(nNumero!=0,SubStr(cEndereco,1,nVirgula-1),cEndereco),34)
    Else
    	lEnderec	:= PadR(IIf(nNumero!=0,SubStr(cEndereco,1,nVirgula-1),cEndereco),60)
    EndIf
EndIf
//��������������������������������������������������������������Ŀ
//�Quando o numero � numerico, obtem-se o complemento            �
//����������������������������������������������������������������
If nNumero <> 0 
	If At(" ",AllTrim(cCompl)) > 0
		cComplemen := Alltrim(SubStr(cCompl,At(" ",AllTrim(cCompl))+1))
	Endif
EndIf
//��������������������������������������������������������������Ŀ
//�Para o numero caracter extrai o complemmento.                 �
//����������������������������������������������������������������
cNumero := StrTran(cNumero,cComplemen,"")

Return({cEnderec,nNumero,cNumero,cComplemen})

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �FisGetTel � Autor �Eduardo Riera          � Data �26.02.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Retorna a estrutura do telefone passado                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpA:  ExpN[1] Codigo do Pais                               ���
���          �       ExpN[2] Codigo de Area                               ���
���          �       ExpN[3] Telefone                                     ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1: Texto do Telefone                                    ���
���          �ExpC2: Codigo de area                                       ���
���          �ExpC3: Codigo do Pais                                       ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function FisGetTelA(cTelefone,cArea,cPais)

Local nX      := 0
Local nCount  := 0  
Local cAux    := ""
Local cNumero := ""
Local lFone   := .T.
Local lArea   := .F.
Local lPais   := .F.

DEFAULT cArea := ""
DEFAULT cPais := ""

//��������������������������������������������������������������Ŀ
//�Verifico o que deve ser extraido do numero do telefone        �
//����������������������������������������������������������������
lArea := Empty(cArea)
lPais := Empty(cPais) .And. lArea
cTelefone := AllTrim(cTelefone)

//��������������������������������������������������������������Ŀ
//�Obtenho o codigo de pais/area e telefone do Telefone          �
//����������������������������������������������������������������

For nX := Len(cTelefone) To 1 Step -1
    nCount++
	cAux := SubStr(cTelefone,nX,1)
	If cAux >= "0" .And. cAux <= "9"
		Do Case
		Case lFone
			cNumero := cAux + cNumero
		Case lArea
			cArea := cAux + cArea
		Case lPais
			cPais := cAux + cPais
		EndCase
		If (nCount == 9)
			lFone := .F.
		Endif
	Else
		Do Case
		Case lFone
			If Len(cNumero) > 5
				lFone := .F.
			EndIf
		Case lArea
			If !Empty(cArea)
				lArea := .F.
			EndIf
		EndCase
	EndIf
Next nX

Return({Val(cPais),Val(cArea),Val(cNumero)})

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �FisGetSer � Autor � Nereu Humberto Junior � Data �27.02.2003���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Retorna a serie valida para os validadores                  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpA:  ExpN[1] Serie valida                                 ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1: Serie a ser validada                                 ���
���          �ExpC2: Tipo do Registro                                     ���
���          �ExpC2: Especie - (Especifico para DES)                      ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function FisGetSerA(cSerie,cTipo,cEspecie,cCFOP,lTSF,lNfse,cArqMag,lSef)

Local lMvSerCat	:= .F.
Local cRetorno	:= ""
Local lSerieSN	:= GetNewPar("MV_ESPNFX5",.F.)

DEFAULT cTipo    := ""
DEFAULT cEspecie := ""
DEFAULT cCFOP    := ""
DEFAULT lTSF     := .F.
DEFAULT lNfse    := .F.
DEFAULT cArqMag  := ""						   
DEFAULT lSef     := .F.


If !lTSF .And. !lNfse
	lMvSerCat 	:=GetNewPar ("MV_SERCAT", .T.)
Endif
If !Empty(cSerie) .And. (lTSF .Or. lMvSerCat)
	If Empty(cTipo)  
		Do Case
		Case Substr(cSerie,1,1)=="B"
			cRetorno := "B  "
		Case Substr(cSerie,1,1)=="C"
			cRetorno := "C  "
		Case Substr(cSerie,1,1)=="E"
			cRetorno := "E  "
		Case Substr(cSerie,1,1)=="U" .And. !lSef  
			cRetorno := "1  "		
		Case Substr(cSerie,1,1)=="U" .And. lSef   //Condicao para quando for gerar o arquivo SEF  pois ele exige que quando for serie unica deve ir "U"  de acordo com o topico 9.7 do manual -> http://www.sefaz.pe.gov.br/sefaz2/upload/arquivos/LEGISLACAO_TRIBUTARIA/SEF/Manual_SEF.pdf
			cRetorno := cSerie    
		Case Substr(cSerie,1,1) $ "1234567890" .And. !Substr(cSerie,2,1) $ "1234567890 " .And. !Substr(cSerie,3,1) $ "1234567890 "
			cRetorno := "1  "
		Case Substr(cSerie,1,1) $ "1234567890 " .And. Substr(cSerie,2,1) $ "1234567890 " .And. Substr(cSerie,3,1) $ "1234567890 "
			cRetorno := cSerie
		OtherWise	
			cRetorno := "1  "
		EndCase
		If !Empty(cEspecie)
			If AllTrim(cEspecie) == "NFS"
				If Substr(cSerie,1,1) $ "ACDE"                                                 
					cRetorno := Substr(cSerie,1,1)+Space(2)
				Else
					aSeries := iif( lSerieSN .And. FindFunction("MaSerEspNF"), Separa(MaSerEspNF(),";"), Separa(GetNewPar("MV_ESPECIE",""),";") )                       
					nPos := aScan(aSeries,{|x| SubStr(x,1,3)=="NFS" })
					If nPos > 0
						cRetorno := SubStr(aSeries[nPos],5,Len(aSeries[nPos]))+Space(3)
						cRetorno := SubStr(cRetorno,1,3)
					EndIf
				EndIf
			Else
				cRetorno := cSerie
			Endif
		Endif
	ElseIf cTipo == "61"
		If Substr(cSerie,1,1) $ "123456789 "
			cRetorno := "D  "
		Else
			cRetorno := "U  "
		Endif
	ElseIf cTipo == "70"                       
		If AllTrim(cEspecie) $ "CA/CTE/CTR/CTA/CTF/NFST" 	 
			If Substr(cSerie,1,1) $ "0123456789UBC"
				cRetorno := SubStr (cSerie, 1, 1)+Space(2)
			Else
				cRetorno := "1"+Space(2)			
			Endif	
		ElseIf !Substr(cSerie,1,1) $ "123456789U " 
	   		If Substr(cSerie,1,1) $ "BC0"
				cRetorno := SubStr (cSerie, 1, 1)
			Else
				cRetorno := "   "
			Endif
		Else
			cRetorno := "1"+Space(2)
		Endif
	ElseIf cTipo == "71"                       		
		If Substr(cSerie,1,1) $ "123456789" .And. IntTms()
			cRetorno := SubStr (cSerie, 1, 1)+Space(2)		
		EndIf	
	Endif
Else
	cRetorno := cSerie
Endif

//�����������������Ŀ
//�Ponto de Entrada �
//�������������������
If (ExistBlock("MTGETS"))
	cRetorno := ExecBlock("MTGETS",.F.,.F.,{cRetorno,cSerie,cTipo})
EndIf
Return(cRetorno)
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �sfVldPReg � Autor � Gustavo G. Rueda      � Data �26.06.2003���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao utilizada para validar o (PREREG) dos INI's, podendo ���
���          �inserir uma condicao ou uma funcao retornando uma string.   |��
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpL: .T./.F.                                               ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpA1: Array contendo todos PreReg                          ���
���          �ExpN2: Controle                                             ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function sfVldPReg (aPreReg, nHandle, lQuebralin)
Local	lRet	:=	.T.
Local	nInd	:=	0
Local	aArea	:=	GetArea ()
Local	xVar
Local   cVar
//
If (Len (aPreReg)<>0)
	For nInd := 1 To Len (aPreReg)
		cVar	:= aPreReg[nInd]
		xVar	:=	&(aPreReg[nInd])
		If (ValType(xVar)=="C") .And. !":="$cVar
			FWrite (nHandle, xVar+Iif(lQuebralin,Chr(13)+Chr(10),""))
			lRet	:=	.T.
		Else
			If (ValType (xVar)=="L")
				If !xVar
					lRet	:=	xVar
					Exit
				EndIf
			Else
				lRet	:=	.T.
			EndIf
		EndIf
	Next nInd
EndIf

RestArea (aArea)

Return (lRet)
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ImpSpool  � Autor � Gustavo G. Rueda      � Data �26.04.2004���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao utilizada atraves dos ini's para impressao em spool  ���
���          �de informacoes sob um layout basico.                        |��
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpL: lRet - .T./.F.                                        ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpC: cNorma - Arquivo INI de configuracao.                 ���
���          �ExpC: cDest - Nome do arquivo txt gerado                    ���
���          �ExpC: cDir - Nome do diretorio onde o txt foi gerado.       ���
�������������������������������������������������������������������������Ĵ��
���OBS       �Para impressao deste relat�rio e necessario que as clausulas���
���          �abaixo estejam configuradas conforme seguem:                ���
���          �1 - Da mesma forma que o (PRE) deve ser criado uma clausula ���
���          �chamada (IMP) onde devera conter um array com a primeira po-���
���          �sicao indicando se o registro deve ser impresso (.T.) ou nao���
���          �(.F.), caso esta clausula nao exista sera considerado .F. e ���
���          �nenhum campo do registro sera impresso. A segunda e a ter-  ���
���          �ceira posicao deste array definido pela clausula (IMP)      ���
���          �he utilizada para indicar a coordenada do                   ���
���          �campo chave de cada registro, onde a segunda posicao indica ���
���          �a posicao inicial e a terceira posicao indica a qtd de len  ���
���          �para este campo. A quarta posicao indica o nome do campo    ���
���          �digitado no ini que indique o campo chave do registro. Ex:  ���
���          �(IMP){.T.,1,2,"SEQ01"}                                      ���
���          �2 - Quando um campo for impresso deve ter um label de 20 ca-|��
���          �racteres contando com as aspas logo apos a qtd de casas de- ���
���          �cimais, em seguida deve se deixar um espaco em branco e in- ���
���          �dicar novamente entre aspas com o tamanho de 20 caracteres  ���
���          �a PICTURE a ser utilizada para a coluna em questao, em se-  ���
���          �guida deve-se deixar outro espaco em branco e idicar o      ���
���          �conteudo do campo, conforme atualmente utilizado. Ex:       ���
���          �SEQ01      C 002 0 "TP             " "@!             " "TO" ���
���          �3 - Para a impressao do relatorio, a qtd de len para uma    ���
���          �coluna he a mesma definido no ini. No exemplo acima, o len  ���
���          �da coluna para o campo SEQ01 he de 2 caracteres, portanto,  ���
���          �o label da coluna deve respeitar esta regra.                ���
���          �4 - Ao final do ini a ser utilizada esta funcao, deve-se    ���
���          �inserir a seguinte chamada de funcao. Ex:                   ���
���          �ImpSpool (MV_PAR03, MV_PAR04, MV_PAR05), onde:              ���
���          �MV_PAR03 = Arquivo ini de configuracao.                     ���
���          �MV_PAR04 = Arquivo txt gerado atraves do ini.               ���
���          �MV_PAR05 = Diretorio destino do arquivo txt gerado.         ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function ImpSpoolA (cNorma, cDest, cDir, aArqSpool,aTrab)
Local 		aArea		:=	GetArea ()
Local		lRet		:=	.T.
Local 		cTitulo  	:= 	STR0010
Local 		cDesc1  	:= 	STR0009
Local 		cDesc2  	:= 	""
Local 		cDesc3  	:= 	""
Local 		wnrel   	:= 	"Mata950"
Local 		NomeProg	:= 	"Mata950"

Private 	Tamanho 	:= 	"G" 	// P/M/G
Private 	Limite  	:= 	220 	// 80/132/220
Private 	lEnd    	:= 	.F.		// Controle de cancelamento do relatorio
Private 	m_pag   	:= 	1  		// Contador de Paginas
Private	    nLastKey	:= 	0  		// Controla o cancelamento da SetPrint e SetDefault
Private 	aReturn 	:= { STR0010, 1,STR0011, 1, 2, 1, "",1 } //"Zebrado"###"Administracao"   

Default     aTrab		:=	{}
//������������������������������������������������������������������������Ŀ
//�Envia para a SetPrinter                                                 �
//��������������������������������������������������������������������������
wnrel	:=	SetPrint ("", NomeProg, "", @cTitulo, cDesc1, cDesc2, cDesc3, .F.,, .F., Tamanho,, .F.)
//
If (nLastKey==27)
	Return (lRet)
Endif
//
SetDefault (aReturn, "")
//
If (nLastKey==27)
	Return (lRet)
Endif
//������������������������������������������������������������������������Ŀ
//�Preparacao do inicio de processamento do arquivo pre-formatado          �
//��������������������������������������������������������������������������
RptStatus ({|lEnd| GeraSpool (cNorma, cDest, cDir, aArqSpool,aTrab)}, cTitulo)
//
If (aReturn[5]==1)
	Set Printer To
	ourspool(wnrel)
Endif
MS_FLUSH()
//���������������Ŀ
//� Restaura area �
//�����������������
RestArea (aArea)
Return (lRet)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �GeraSpool � Autor � Gustavo G. Rueda      � Data �26.04.2004���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de impressao.                                        ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpL: lRet - .T./.F.                                        ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpC: cNorma - Arquivo INI de configuracao.                 ���
���          �ExpC: cDest - Nome do arquivo txt gerado                    ���
���          �ExpC: cDir - Nome do diretorio onde o txt foi gerado.       ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function GeraSpool (cNorma, cDest, cDir, aArqSpool,aTrab)
Local	lRet		:=	.T.
Local	nTamNorma	:=	0
Local	nTamTxt		:=	0
Local	nReadNorma	:=	0
Local	nReadTxt	:=	0
Local	nHandleNorma:=	0
Local	nHandleTxt	:=	0
Local	nByteNorma	:=	1
Local	nByteTxt	:=	1
Local	nTamCol		:=	0
Local	cTitulo		:=	""
Local	lFirst		:=	.T.
Local	aColImp		:=	{}
Local	aImprime	:=	{.F.,,,,.F.}	//1-Indica se imprime (.T. ou .F.), 2-Posicao inicial chave registro, 3-Len do indentificador, 4-Nome do campo na estrutura do ini, 5-Analitico(.f.) ou Sintetico (.t.)
Local	aLidosNorma	:=	{}
Local	aLidosTxt	:=	{}
Local	cLinhaNorma	:=	""
Local	cLinhaTxt	:=	""
Local	cLinha		:=	""
Local	cLinha2		:=	""
Local	cChaveNorma	:=	""
Local	cChaveTxt	:=	""
Local	nInd		:=	1
Local	aColuna		:=	{}
Local	nLin		:=	99
Local	nTipo		:=	18
Local	nPosInicial	:=	1
Local	nIniCampo	:=	0
Local	nLenCampo	:=	0
Local	cDetCampo	:=	""
Local	aDetImp		:=	{}
Local	cTipoCampo	:=	""
Local	cMaskCampo	:=	""
Local	cFundo		:=	""
Local	cDivisao	:=	""
Local	lNumber		:=	.T.
Local	lGerou		:=	.T.
Local	cBarra		:=	""
Local	nLinPag		:=	60
Local	lLinha		:=	.T.
Local	cLegenda	:=	""
Local	cDecimal	:=	""
Local	aCampos		:=	{}
Local	nPosCampos	:=	0
Local	aArqSpoolX	:=	aArqSpool
Local	nI			:=	0
Local	lLoop		:=	.F.
Local	lVariosArq	:=	Len (aArqSpoolX)>0
Local	cDelimitador:=	""
Local	nCmpDel		:=	0
Local	lSintetico	:=	aImprime[5]
Local	nLenCmp		:=	0
Local	cArqBloco	:=	""	//Nome do arquivo para controle, pois com este nome me certifico de que o arquivo TXT

Default aTrab		:=	{}

//  gerado aberto no momento se refere a IN ou a um bloco dela (no caso de varios arquivos. Ex: NORMA086/SINCONF)
//
If (File(cNorma)) .And. ((File(cDir+cDest)) .Or. lVariosArq)
	nHandleNorma	:=	FOpen (cNorma)
	nTamNorma		:=	FSeek (nHandleNorma, 0, 2)
	FSeek (nHandleNorma, 0, 0)
	nReadNorma 	:= 	FRead (nHandleNorma, @cLinha, nTamNorma)
	// 
	lVariosArq	:=	Len(aArqSpoolX)>1
	If !lVariosArq  

		//������������������������������������������������������������Ŀ
		//�Tratamento para quando for uma IN para um arquivo TXT gerado�
		//��������������������������������������������������������������
		cArqBloco	:=	aArqSpoolX[1]
	EndIf
	//
	For nI := 1 To Len (aArqSpoolX)
		FT_FUse(aArqSpoolX[nI])
		FT_FGotop()
		//
		While nByteNorma<=nTamNorma .And. ( !FT_FEof() )
			aLidosNorma	:=	LerLinha (cLinha, nByteNorma)	//Funcao utilizada para ler registro a registro do txt gerado.
			cLinhaNorma	:=	Subs( aLidosNorma[1], 1 , Len(Alltrim( aLidosNorma[1] ))-1)
			nByteNorma	:=	aLidosNorma[2]
			//
			If (lVariosArq)	//Somente Para inis que utilizam a clausula (ARQ)
				If (AllTrim (SubStr (cLinhaNorma, 1, 1))$"[{")
					lLoop	:=	.F.
				EndIf
				//
				If (lLoop)
					Loop
				EndIf
			EndIf
			//
			Do Case
			Case (AllTrim (SubStr (cLinhaNorma, 1, 1))$"[{") .Or. nByteNorma>nTamNorma
				//��������������������������������������������������������������������Ŀ
				//�Impressao efetuada a cada bloco ou quando o proximo while for falso.�
				//����������������������������������������������������������������������
				If (aImprime[1]) .And. !(lFirst) .And. (aArqSpoolX[nI]$cArqBloco)
					cFundo		:=	""
					cDivisao	:=	""
					cBarra		:=	""
					//�������������������������������������������������������������������������������������Ŀ
					//�Neste for monta-se o nome das colunas e o fundo para ser utilizado pela funcao FMTLIN�
					//���������������������������������������������������������������������������������������
					For nInd := 1 To Len (aColImp)
						nTamCol	:=	SpoolGetMask( aColImp[nInd][4] , aColImp[nInd][5] )
						aAdd (aColuna, AllTrim (SubStr (aColImp[nInd][7], 1, nTamCol)))
						//
						cFundo		+=	"|"+Replicate ("#", nTamCol)
						cDivisao	+=	"+"+Replicate ("-", nTamCol)
					Next nInd
					cFundo		+=	"|"
					cDivisao	+=	"+"
					cBarra		:=	Replicate ("-", Len (cFundo))
					//
					While ( !FT_FEof() )
						//
						lGerou	:=	.F.
						lNumber	:=	.F.
						If ValType (cChaveNorma)=="N"
							lNumber		:=	.T.
							cChaveNorma	:=	StrZero (cChaveNorma, Len (AllTrim (cChaveTxt)))
						EndIf
						//�������������������������������������������������������������������������������������������������������������������������Ŀ
						//�Padronizo a comparacao, pois pode ocorrer de em algum registro o len do campo chave for diferente de um outro registro.  �
						//�Ex: Por default, na maioria dos registros os campos chaves possuem 2 caracteres mais em um registro em especifico,       �
						//�o campo chave he formado por 3 caracteres, portanto na proxima passagem por esta linha, quando a qtd de caracteres for 2,�
						//�tera de ser transformada para 2 caracteres antes da comparacao. O exemplo he de 2, mas pode ser a qualquer qtd.          �
						//���������������������������������������������������������������������������������������������������������������������������
						If  cChaveNorma==Left (cChaveTxt, Len (AllTrim (cChaveNorma)))
							cChaveTxt	:=	Left (cChaveTxt, Len (AllTrim (cChaveNorma)))
						EndIf
						//
						If cChaveNorma<>cChaveTxt
							cLinhaTxt	:=	FT_FReadLn()

							If (lVariosArq)	//Se o ini gerar mais de um arquivo aceito todos os registros contidos no arquivo como o mesmo bloco.
								cChaveTxt	:=	cChaveNorma		//Somente Para inis que utilizam a clausula (ARQ)
							Else
								cChaveTxt	:=	SubStr (cLinhaTxt, aImprime[2], aImprime[3])
							EndIf
							//
							If lNumber
								cChaveNorma	:=	StrZero (Val (cChaveNorma), Len (AllTrim (cChaveTxt)))
							EndIf
						EndIf
						//
						If (cChaveNorma==cChaveTxt)
							lGerou	:=	.T.
							//
							If nLin>=nLinPag
								nLin	:=	cabec (STR0008, "", "", "MATA950", "G", nTipo)
							EndIf
							//
							nLin++
							FmtLin ({cTitulo}, STR0007,,"@X", @nLin)
							FmtLin ({}, cBarra,,, @nLin)
							FmtLin (aColuna, cFundo,,"@X", @nLin)
							FmtLin ({}, cDivisao,,, @nLin)
							//
							lLinha	:=	.F.
							//
							While ( !FT_FEof() ) .And. ( cChaveNorma == cChaveTxt )
								//Soh zero quando for analitico pois nao precisarah acumular (no caso do sintetico)
								If !lSintetico
									aDetImp	:=	{}
								EndIf
								//
								If nLin>=nLinPag
									If (lLinha)
										lLinha	:=	.F.
										FmtLin ({}, cBarra,,, @nLin)
									EndIf
									FmtLin ({}, STR0013,,, @nLin)
									nLin	:=	cabec (STR0008, "", "", "MATA950", "G", nTipo)
									nLin++
									FmtLin ({cTitulo}, STR0007,,"@X", @nLin)
									FmtLin ({}, cBarra,,, @nLin)
								EndIf
								//
								For nInd := 1 To Len (aColImp)
									cTipoCampo	:=	aColImp[nInd][2]
									nIniCampo	:=	aColImp[nInd][3]
									nLenCampo	:=	aColImp[nInd][4]
									nDecimal	:=	aColImp[nInd][5]
									//Quando for analitico gero linha a linha do arquivo texto
									If !lSintetico
										If Empty (cDelimitador)
											If ("N"$cTipoCampo)
												If (nDecimal<>0)
													cMaskCampo	:=	A950Tm (Val (SubStr (cLinhaTxt, nIniCampo, nLenCampo)), nLenCampo, nDecimal)
													cDetCampo	:=	IntToDec (SubStr (cLinhaTxt, nIniCampo, nLenCampo), cMaskCampo, nDecimal)
												Else
													cDetCampo	:=	SubStr (cLinhaTxt, nIniCampo, nLenCampo)
												EndIf
											ElseIf ("C"$cTipoCampo)
												cMaskCampo	:=	A950Tm (SubStr (cLinhaTxt, nIniCampo, nLenCampo), nLenCampo, nDecimal)
												cDetCampo	:=	Transform (SubStr (cLinhaTxt, nIniCampo, nLenCampo), cMaskCampo)
											ElseIf ("D"$cTipoCampo)
												cDetCampo	:=	StrZero (Day(StoD (SubStr (cLinhaTxt, nIniCampo, nLenCampo))),2)+"/"+StrZero (Month(StoD (SubStr (cLinhaTxt, nIniCampo, nLenCampo))),2)+"/"+Right (StrZero (Year(StoD (SubStr (cLinhaTxt, nIniCampo, nLenCampo))),4), 2)
											EndIf
										Else
											nCmpDel	:=	aColImp[nInd][8]
											cDetCampo	:=	RetCmpDel (cLinhaTxt, cDelimitador, nCmpDel)
										EndIf
										//
										aAdd (aDetImp, cDetCampo)

										//Se for sintetico soh gero o totalizador
									Else
										cDetCampo	:=	Space (nLenCampo)
										//Monto o totalizador somente para campos numericos
										If ("N"$cTipoCampo)
											//Este 6 define que somente irei pegar campo que armazenarah valor a ser
											//	totalizado. Ex: Aliquota possui no maximo 6 (999.99)
											If (nDecimal<>0) .And. (nLenCampo>6)
												cMaskCampo	:=	A950Tm (Val (SubStr (cLinhaTxt, nIniCampo, nLenCampo)), nLenCampo, nDecimal)
												cDetCampo	:=	SubStr (cLinhaTxt, nIniCampo, nLenCampo)
												//
												If (Len (aDetImp)<Len (aColImp))//Para a primeira linha do txt inicializo o array com um add, nas proximas vou acumulando
													aAdd (aDetImp, {Val (cDetCampo), cMaskCampo, nDecimal})
												Else
													aDetImp[nInd][1]	+=	Val (cDetCampo)
												EndIf
											EndIf
										EndIf
										//
										//Este add somente serah executado para a primeira linha quando o conteudo da
										//	variavel cDetCampo estiver em branco.
										If Empty (cDetCampo) .And. (Len (aDetImp)<Len (aColImp))
											aAdd (aDetImp, {cDetCampo, "", 0})
										EndIf
									EndIf
								Next nInd
								//
								//Somente gero linha a linha quando for analitico
								If !lSintetico
									FmtLin (aDetImp, cFundo,,, @nLin)
								EndIf
								lLinha	:=	.T.
								//
								FT_FSkip()
								cLinhaTxt := FT_FReadLn()
								//
								If (lVariosArq)	//Se o ini gerar mais de um arquivo aceito todos os registros contidos no arquivo como o mesmo bloco.
									cChaveTxt	:=	cChaveNorma		//Somente Para inis que utilizam a clausula (ARQ)
								Else
									cChaveTxt	:=	SubStr (cLinhaTxt, aImprime[2], aImprime[3])
								EndIf
							EndDo
							//
							If (cChaveNorma<>cChaveTxt)
								Exit
							EndIf
						Else
							FT_FSkip()
							cLinhaTxt := FT_FReadLn()
							//
							If (lVariosArq)	//Se o ini gerar mais de um arquivo aceito todos os registros contidos no arquivo como o mesmo bloco.
								cChaveTxt	:=	cChaveNorma		//Somente Para inis que utilizam a clausula (ARQ)
							Else
								cChaveTxt	:=	SubStr (cLinhaTxt, aImprime[2], aImprime[3])
							EndIf
						EndIf
					EndDo
					//
					If (lGerou)
						//
						//Somente gero quando for sintetico pois trata-se do totalizador de cada registro
						If lSintetico
							For nInd := 1 To Len (aDetImp)
								cDetCampo	:=	aDetImp[nInd][1]
								If !Empty (cDetCampo)
									cDetCampo	:=	IntToDec (aDetImp[nInd][1], aDetImp[nInd][2], aDetImp[nInd][3])
								EndIf
								aDetImp[nInd]	:=	cDetCampo
							Next nInd
							FmtLin (aDetImp, cFundo,,, @nLin)
						EndIf
						FmtLin ({}, cBarra,,, @nLin)
						If !Empty (cLegenda)
							FmtLin ({cLegenda}, STR0014,,"@X", @nLin)
							cLegenda	:=	""
						EndIf
					Else
						FT_FGotop()
					EndIf
				EndIf
				//
				cTitulo		:=	AllTrim (SubStr (cLinhaNorma, 5, At ("]", cLinhaNorma)-5))
				lFirst		:=	.F.
				aImprime	:=	{.F.,,,,.F.}
				aColImp		:=	{}
				aColuna		:=	{}
				nPosInicial	:=	1
				cChaveNorma	:=	""
				aCampos		:=	{}
				cDelimitador:= 	""
				nCmpDel		:=	0
				aDetImp		:=	{}
				//
				If (lVariosArq)	//Somente para ini com clausula (ARQ)
					cChaveTxt	:=	""
				EndIf
				//
			Case "(DEL)"$AllTrim (SubStr (cLinhaNorma, 1, 5))
				cDelimitador:=	SubStr (AllTrim (SubStr (cLinhaNorma, 6)), 1, 1)

			Case "(ARQ)"$AllTrim (SubStr (cLinhaNorma, 1, 5))
				cArqBloco	:=	AllTrim (SubStr (cLinhaNorma, 6))
				If ("&"$cArqBloco)
					cArqBloco	:=	&(AllTrim(SubStr (cArqBloco, At ("&", cArqBloco)+1)))
				EndIf
				cArqBloco	:=	If(aScan(aTrab,{|ax|AllTrim(aX[2])$AllTrim(cArqBloco)})>0,aTrab[aScan(aTrab,{|ax|AllTrim(aX[2])$AllTrim(cArqBloco)}),1],cArqBloco)
				cArqBloco	:=	AllTrim(cArqBloco)

				If !(aArqSpoolX[nI]$cArqBloco)
					lLoop	:=	.T.
				EndIf

			Case "(IMP)"$AllTrim (SubStr (cLinhaNorma, 1, 5))
				aImprime	:=	&(AllTrim (SubStr (cLinhaNorma, 6)))
				lSintetico 	:= 	Iif (Len (aImprime)<>5, .F., &(aImprime[5]))

			Case "(LEG)"$AllTrim (SubStr (cLinhaNorma, 1, 5))
				cLegenda	:=	&(AllTrim (SubStr (cLinhaNorma, 6)))

			Case "(CMP)"$AllTrim (SubStr (cLinhaNorma, 1, 5))
				aCampos	:=	&(AllTrim (SubStr (cLinhaNorma, 6)))

			Case !(AllTrim (SubStr (cLinhaNorma, 1, 1))$"(") .And. (aImprime[1])
				//
				nCmpDel++
				nPosCampos	:=	aScan (aCampos, {|aX| aX[1]==AllTrim (SubStr (cLinhaNorma, 01, 10))})
				//
				If nPosCampos<>0
					nLenCmp	:=	Iif (Len (aCampos[nPosCampos])==3, aCampos[nPosCampos][3], Val(SubStr (cLinhaNorma, 14, 3)))
					aAdd (aColImp, {AllTrim (SubStr (cLinhaNorma, 01, 10)), SubStr (cLinhaNorma, 12, 01), nPosInicial, nLenCmp, Val (SubStr (cLinhaNorma, 18, 01)), SubStr (cLinhaNorma, 20), Iif (Empty (aCampos[nPosCampos][2]), aCampos[nPosCampos][1], aCampos[nPosCampos][2]), nCmpDel})
				EndIf
				//��������������������������������������������������������������������������������������Ŀ
				//�Este if trata o codigo de identificacao de cada registro como fixo no proprio ini para�
				//�posterior associacao com o txt gerado.                                                �
				//����������������������������������������������������������������������������������������
				If aImprime[1] .And. (AllTrim (SubStr (cLinhaNorma, 01, 10))$aImprime[4]) .And. !(lVariosArq)
					cChaveNorma	:=	&(AllTrim (SubStr (cLinhaNorma, 20)))

				ElseIf (lVariosArq)	//Somente Para inis que utilizam a clausula (ARQ)
					//�������������������������������������������������������������������������������������������������������������������������Ŀ
					//�Se o ini gerar varios arquivos como por exemplo a NORMA086, essume-se que cada arquivo identifica um registro  e o codigo�
					//�de identificacao de cada registro e assumido como ALL.                                                                   �
					//���������������������������������������������������������������������������������������������������������������������������
					cChaveNorma	:=	"ALL"
				EndIf
				//
				nPosInicial	+=	Val(SubStr (cLinhaNorma, 14, 3))
			EndCase
			//
		EndDo
		//
		FT_FUse()
	Next nI
	//
	FClose (nHandleNorma)
	FT_FUse()
EndIf
Return (lRet)
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �LerLinha  � Autor � Gustavo G. Rueda      � Data �28.04.2004���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao utilizada para ler linha-a-linha de um arquivo texto.���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpA[1]: String lida                                        ���
���          �ExpA[2]: Bytes lidos                                        ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpC: cLinha - Buffer do arquivo a ser processado           ���
���          �ExpN: nInicio - Byte inicial para leitura                   ���
�������������������������������������������������������������������������Ĵ��
���Uso       �MATA950        |                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function LerLinha (cLinha, nInicio)
Local 	cString 	:= 	""
Local	nLidos 		:=	nInicio
//
While .T.
	cChar 		:= 	SubStr (cLinha, nLidos, 1)
	cString		+=	cChar
	nLidos++
	//
	If cChar==chr (10)
		cString := cString
		Exit
	EndIf
EndDo
Return {cString, nLidos}
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �A950Tm    � Autor � Gustavo G. Rueda      � Data �28.04.2004���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao utilizada para retornar a Picture para um numero ou  ���
���          �caracter.                                                   ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpC: cRetPic - Picture formada no processamento. No caso   ���
���          �de Numero sera retornado @E.... e no caso de caracter @!.   ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpU: uCampo - Conteudo de um campo a ser processado        ���
���          �ExpN: nLen - Numero de bytes para formatar a picture        ���
���          �ExpN: nDec - Numero de bytes para a casa decimal            ���
���          �ExpN: lEstrang - Nao considera nenhuma picture para casos   ���
���          �estrangeiros.                                               ���
�������������������������������������������������������������������������Ĵ��
���Uso       �MATA950        |                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function A950Tm (uCampo, nLen, nDec, lEstrang)
Local	cPic		:=	""
Local	cRetPic		:=	""
Local	nInicio		:=	0
//
lEstrang := Iif (lEstrang==Nil, .F., lEstrang)
//
If nDec==NIL
	nDec	:=	GetMv("mv_cent")
EndIf
//
If Valtype (uCampo)=="N"
	cPic := Iif (GetMv("mv_milhar"), "999,999,999,999,999,999,999,999", "9999999999999999999999999999999")+Iif (nDec>0, ("."+Replicate ("9", nDec)),"")
	nLen := SpoolGetMask( nLen , nDec ) 
ElseIf Valtype (uCampo)=="C"
	cRetPic := "@!"
EndIf
//
nInicio	:=	Len (cPic)-nLen
nInicio++
//
While (nInicio<=Len (cPic)) .And. Valtype (uCampo)=="N"
	If !(nInicio==Len (cPic)-nLen .And. SubStr (cPic, nInicio, 1)$".,")
		cRetPic	+=		SubStr (cPic, nInicio, 1)
	EndIf
	//
	nInicio++
End
//
If !(lEstrang) .And. !"@!"$cRetPic
	cRetPic	:=	"@E "+cRetPic
EndIf
Return (cRetPic)
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �IntToDec  � Autor �Gustavo G. Rueda       � Data �28.04.2004���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao para conversao dos valores gravados nos arquivos     ���
���          � textos conforme instrucao normativa. Especificamente para  ���
���          � numeros decimais.                                          ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpN -> nDec - numero convertido.                           ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpC -> cInt - Numerono formato de caracter a ser convertido���
���          �ExpC -> cMask - Mascara a ser utilizada apos conversao.     ���
���          �ExpN -> nDec - Qtd de casas decimais.                       ���
�������������������������������������������������������������������������Ĵ��
���Uso       �MATA950        |                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function IntToDec (cInt, cMask, nDec)
Local		cDec	:=	""
//
nDec := Iif (nDec==Nil, 2, nDec)
If (ValType (cInt)$"N")
	cInt	:=	Str (cInt)
EndIf
//
cDec	:=	Transform (Val (Left (AllTrim (cInt), Len (AllTrim (cInt))-nDec)+"."+Right (AllTrim (cInt), nDec)), cMask)
Return (cDec)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RetTotICMS�Autor  �Sergio S. Fuzinaka  � Data � 05/09/2006  ���
�������������������������������������������������������������������������͹��
���Descricao �Retorna o Total de ICMS Proprio e ST do Produto sujeito a ST���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �MATA950	                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function RetTotICMS(cProduto,dUltFec,nSaldo,c88Ind,aNFsProc,lRgEspSt,lUsaSFT,nMargem,dDtStMG,l88AltReg)

Local aArea		:= GetArea()
Local aRet		:= {0,0,0,0}
Local aDtFec	:= {}	//Datas de Fechamento do Produto
Local aChave	:= {"","","","",""}
Local aRetMG	:= {}

Local bCond		:= {||}

Local cAliasSD1	:= "SD1"
Local cChave	:= "" 
Local cMV_ESTICM:= SuperGetMV("MV_ESTICM") 
Local cDestino	:= ""
Local cChvSoma	:= ""     


Local lMonta88	:= .T.
Local lRecalST	:= GetNewPar("MV_RECALST",.F.) 
Local lMediaST	:= GetNewPar("MV_MEDIAST",.T.)

Local nQuant	:= 0
Local nRecno	:= 0
Local nVlrUnit	:= 0	//Valor Unitario do ICMS PROPRIO
Local nVlrUnST	:= 0	//Valor Unitario do ICMS ST
Local nSldDif	:= 0	//Diferenca de Saldo
Local nValIcms	:= 0	//ICMS PROPRIO Proporcional
Local nIcmsRet	:= 0	//ICMS ST Proporcional
Local nRetInd	:= 0
Local nX		:= 0
Local nAlqRet	:= 0
Local nBaseRet	:= 0 
Local nNfsProc 	:= 0  
Local nItem		:= 0    
Local nQtdEntr	:= 0                 
Local nPropor   := 1 
Local nQtdNec   := 0      
Local nBsIcmMG 	:= 0
Local nAlIcmMG 	:= 0
Local nBaseSol	:= 0
Local nBasePro	:= 0
Local nTotIcmRet := 0
Local nTotIcms   := 0

#IFDEF TOP
	Local aStruSD1 	:= 	{}
	Local cQuery   	:=	""
	Local nY		:= 0
#ELSE
	Local cInd		:=	""
	Local cFiltro	:=	""
#ENDIF

DEfault l88AltReg	:= .F.

dbSelectArea("SF1")
SF1->(dbSetOrder(1))
//��������������������������������������������������Ŀ
//� Array contendo as datas de fechamento do produto �
//����������������������������������������������������
dbSelectArea("SB9")
dbSetOrder(1)
If dbSeek(xFilial("SB9")+cProduto)
	While !Eof() .And. xFilial("SB9") == SB9->B9_FILIAL .And. cProduto == SB9->B9_COD
		If Ascan(aDtFec,{|x| x[1]==SB9->B9_DATA}) == 0
			AADD(aDtFec,{SB9->B9_DATA})
		Endif
		dbSkip()
	Enddo
	AADD(aDtFec,{CtoD("")})
	aSort(aDtFec,,,{|x,y| x[1]>y[1]}) 
	
	//��������������������������������������������������Ŀ
	//� As ultimas Notas Fiscais de Compra do Produto    �
	//����������������������������������������������������
	dbSelectArea("SD1")
	dbSetOrder(6)

	For nX := 1 To Len(aDtFec)
		If nX > 1
			#IFDEF TOP
				dbSelectArea(cAliasSD1)
				dbCloseArea()
			#ELSE
				dbSelectArea(cAliasSD1)
				RetIndex(cAliasSd1)
				FErase(cInd+OrdBagExt())
			#ENDIF
		Endif		
		#IFDEF TOP
			cAliasSD1 := "AliasSD1"
			aStruSD1  := SD1->(dbStruct())
			cQuery    := "SELECT D1_FILIAL,D1_TIPO,D1_DTDIGIT,D1_VALICM,D1_QUANT,D1_ICMSRET,D1_BRICMS,"
			cQuery    += "D1_DOC,D1_SERIE,D1_ITEM,D1_FORNECE,D1_LOJA,D1_COD,D1_CF,D1_EMISSAO,D1_NFORI," 
			cQuery    += "D1_SERIORI,D1_ITEMORI,D1_BASEICM"
			If l88AltReg
				cQuery    += ",D1_BASNDES, D1_ICMNDES " 
			EndIF 
			cQuery    += " FROM " + RetSqlName("SD1") + " "
			cQuery    += "WHERE D1_FILIAL = '" + xFilial("SD1") + "' AND "
			cQuery    += "D1_COD = '" + cProduto + "' AND "
			cQuery    += "D1_TIPO NOT IN('P','I','C') AND "	
			cQuery    += "(D1_DTDIGIT < '" + Dtos(dUltFec) + "' OR "
			cQuery    += "D1_DTDIGIT >= '" + Dtos(aDtFec[nX][1]) + "') AND "			
			//����������������������������������������������������������������������Ŀ
			//�Verifica se as entradas sem calculo de ST devem ser processadas tambem�
			//������������������������������������������������������������������������
			If !lRgEspSt
				IF l88AltReg
					cQuery	+= "(D1_BRICMS > 0 OR D1_BASNDES > 0  )AND "
				Else
					cQuery	+= "D1_BRICMS > 0 AND "
				EndIF
			Endif
			cQuery    += "D_E_L_E_T_= ' ' "
			cQuery    += "ORDER BY D1_DTDIGIT DESC"
			cQuery    := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD1,.T.,.T.)
			For nY := 1 To Len(aStruSD1)
				If ( aStruSD1[nY][2] <> "C" )
					TcSetField(cAliasSD1,aStruSD1[nY][1],aStruSD1[nY][2],aStruSD1[nY][3],aStruSD1[nY][4])
				EndIf
			Next nY
		#ELSE
			cInd	:=	CriaTrab(NIL,.F.)
			cFiltro	:=	"D1_FILIAL == '" + xFilial("SD1") + "'"
			If !lRgEspSt
				cFiltro	+=	" .And. !(D1_TIPO $ 'P/I/C') .And. D1_BRICMS > 0 .And. D1_COD == '" + cProduto + "' .And. Dtos(D1_DTDIGIT) < '" + Dtos(dUltFec) + "'.And. Dtos(D1_DTDIGIT) >= '" + Dtos(aDtFec[nX][1]) + "'"
			Else
				cFiltro	+=	" .And. !(D1_TIPO $ 'P/I/C') .And. D1_COD == '" + cProduto + "' .And. Dtos(D1_DTDIGIT) < '" + Dtos(dUltFec) + "'.And. Dtos(D1_DTDIGIT) >= '" + Dtos(aDtFec[nX][1]) + "'"
			Endif
			IndRegua (cAliasSD1,cInd,IndexKey(),,cFiltro,Nil,.F.)
			dbClearIndex()	
			nRetInd := RetIndex(cAliasSD1)
			dbSetIndex(c88Ind+OrdBagExt())  
			dbSetIndex(cInd+OrdBagExt())
			dbSetOrder(nRetInd+2)
			dbGoTop()			
		#ENDIF

		//����������������������������������������������������������������������������������������dd�
		//�Verifica as situacoes que podem permitir a geracao dos registros 88 quando as entradas:�
		//�- NF de entrada com ICMS ST calculado                                                  �
		//�- NF de entrada sem ICMS ST calculado, mas com margem de ST no cadastro do produto     �
		//�- NF de entrada sem ICMS ST, mas com Regime Especial                                   �
		//����������������������������������������������������������������������������������������dd�
		nQuant := 0              
		If RetMonta88((cAliasSD1)->D1_ICMSRET,(cAliasSD1)->D1_SERIE,;
						(cAliasSD1)->D1_DOC,(cAliasSD1)->D1_FORNECE,(cAliasSD1)->D1_LOJA,;
						(cAliasSD1)->D1_ITEM,(cAliasSD1)->D1_COD,lUsaSFT,nMargem,(cAliasSD1)->D1_CF)

			//����������������������������������������������������������������������������������Ŀ
			//�Armazena o item da nota fiscal que foi processado para composicao do estoque de ST�
			//������������������������������������������������������������������������������������
			cChave := (cAliasSD1)->D1_FILIAL+(cAliasSD1)->D1_DOC+(cAliasSD1)->D1_SERIE+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA+(cAliasSD1)->D1_COD+(cAliasSD1)->D1_ITEM
			If aScan(aNFsProc,{|x| x[1]+x[2]+x[3]+x[4]+x[5]+x[6]+x[7]==cChave}) == 0
				Aadd(aNFsProc,{(cAliasSD1)->D1_FILIAL,(cAliasSD1)->D1_DOC,(cAliasSD1)->D1_SERIE,(cAliasSD1)->D1_FORNECE,(cAliasSD1)->D1_LOJA,(cAliasSD1)->D1_COD,(cAliasSD1)->D1_ITEM,0})
			Endif

			dbEval({|| nQuant += D1_QUANT})
		Endif
		
		If nQuant >= nSaldo
			Exit
		Endif
	Next nX

	dbSelectArea(cAliasSD1)
	#IFDEF TOP
		bCond := {|| !Eof()}
		dbGoTop()
	#ELSE
		bCond := {|| !Bof()}	
		dbGoBottom()	
	#ENDIF
	nQuant := 0
	While Eval(bCond) .And. (nQuant < nSaldo)
	
		nValIcms	:= (cAliasSD1)->D1_VALICM	//ICMS PROPRIO
		nBaseRet	:= (cAliasSD1)->D1_BRICMS
		nIcmsRet	:= (cAliasSD1)->D1_ICMSRET + Iif(l88AltReg,(cAliasSD1)->D1_ICMNDES  , 0 )	//ICMS ST
		nBaseSol	+= (cAliasSD1)->D1_BRICMS + Iif(l88AltReg, (cAliasSD1)->D1_BASNDES , 0 ) //Base Icms St
		nBasePro	+= (cAliasSD1)->D1_BASEICM //Base Icms Proprio
		//��������������������������������������������������������������������������Ŀ
		//�Quando nao houve o calculo do ST, mas existe a margem de lucro na entrada,�
		//�o valor deve ser calculado para compor o registro, desde que o movimento  �
		//�seja anterior a data de corte do parametro MV_DTSTMG                      �
		//����������������������������������������������������������������������������
		If lRecalST .And. nIcmsRet == 0 .And. !Empty(dDTSTMG) .And. (cAliasSD1)->D1_DTDIGIT <= dDTSTMG .And. nMargem > 0
			aChave[01] := xFilial("SD1")
			aChave[02] := (cAliasSD1)->D1_DOC
			aChave[03] := (cAliasSD1)->D1_SERIE
			aChave[04] := (cAliasSD1)->D1_FORNECE
			aChave[05] := (cAliasSD1)->D1_LOJA
			nBaseRet := Ma950RecST(@nIcmsRet,aChave,@nItem)
		Endif

		//�����������������������������������������������������������������������������������������Ŀ
		//�Ponto de entrada para retornar os valores de ICMS e ST nas notas de devolucao.           �
		//�Necessario ao fato de que, quando devolvo uma NF de saida sem calculo de ICMS            �
		//�ou ST, devera de alguma forma buscar os valores da nota de entrada da mercadoria vendida.�
		//�������������������������������������������������������������������������������������������
		If Existblock("A940STMG")
			aRetMG := Execblock("A940STMG",.F.,.F.,{cAliasSD1,;
					(cAliasSD1)->D1_FILIAL,;
					(cAliasSD1)->D1_DOC,;
					(cAliasSD1)->D1_SERIE,;
					(cAliasSD1)->D1_FORNECE,;
					(cAliasSD1)->D1_LOJA,;
					(cAliasSD1)->D1_TIPO}) 
			If Len(aRetMG) >= 5
		    	nBaseRet 	:= aRetMG[02]
		        nValIcms	:= aRetMG[04]
		        nIcmsRet	:= aRetMG[05]
		    Endif
	    Endif
		//����������������������������������������������������������������������������������������dd�
		//�Verifica as situacoes que podem permitir a geracao dos registros 88 quando as entradas:�
		//�- NF de entrada com ICMS ST calculado                                                  �
		//�- NF de entrada sem ICMS ST calculado, mas com margem de ST no cadastro do produto     �
		//�- NF de entrada sem ICMS ST, mas com Regime Especial                                   �
		//����������������������������������������������������������������������������������������dd�
		If RetMonta88((cAliasSD1)->D1_ICMSRET,(cAliasSD1)->D1_SERIE,;
						(cAliasSD1)->D1_DOC,(cAliasSD1)->D1_FORNECE,(cAliasSD1)->D1_LOJA,;
						(cAliasSD1)->D1_ITEM,(cAliasSD1)->D1_COD,lUsaSFT,nMargem,(cAliasSD1)->D1_CF)
	
		    If (cAliasSD1)->D1_TIPO == "N"
				nRecno := (cAliasSD1)->(Recno())
			    NfCompl(cAliasSD1,@nValIcms,@nIcmsRet,dUltFec,nRetInd,@aNFsProc,lUsaSFT,lRgEspSt,nMargem,nAlqRet,dDTSTMG,lRecalST,@nBaseSol,@nBasePro)
				dbSelectArea(cAliasSD1)
				#IFNDEF TOP
					dbSetOrder(nRetInd+2)
				#ENDIF
		   		dbGoTo(nRecno)
		    Endif
		
			//��������������������������������������������������������������������
			//�Verifica se o calculo eh pela media das ultimas entradas ou apenas�
			//�utiliza a quantidade necessaria do documento, sem aplicar a media.�
			//��������������������������������������������������������������������
			If lMediaST
				//����������������������������������������������������������������������Ŀ
				//�Soma os valores unitarios de ICMS Proprio e de ICMS ST de             �
				//�cada entrada processada para se calcular a media das ultimas entradas.�
				//������������������������������������������������������������������������
				//nVlrUnit	+= (nValIcms / (cAliasSD1)->D1_QUANT)				
				//nVlrUnST	+= ((nIcmsRet / (cAliasSD1)->D1_QUANT)
				
				nTotIcmRet  += nIcmsRet
				nTotIcms    += nValIcms
				nVlrUnit	+= ((nValIcms / (cAliasSD1)->D1_QUANT)*nValIcms)				
				nVlrUnST	+= ((nIcmsRet / (cAliasSD1)->D1_QUANT)*nIcmsRet)  
	
				//������������������������������������������������Ŀ
				//�Verifica quantas notas de entrada foram         �
				//�processadas para se chegar no saldo apresentado.�
				//��������������������������������������������������
				If cChvSoma <> (cAliasSD1)->D1_FILIAL+(cAliasSD1)->D1_DOC+(cAliasSD1)->D1_SERIE+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA
					cChvSoma := (cAliasSD1)->D1_FILIAL+(cAliasSD1)->D1_DOC+(cAliasSD1)->D1_SERIE+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA
					nQtdEntr += 1
				Endif 
				
				//��������������������������������������������������������������������Ŀ
				//�Se a quantidade da nota posicionada, somada ao saldo ja processado, �
				//�compor o estoque disponivel, eh calculada a media ponderada dos 	   �
				//�valores doICMS ST e do ICMS Proprio.                                �
				//����������������������������������������������������������������������
				If (nQuant + (cAliasSD1)->D1_QUANT) >= nSaldo
					
					//nValIcms	:= (nVlrUnit / nQtdEntr) * nSaldo
					//nIcmsRet	:= (nVlrUnST / nQtdEntr) * nSaldo					
					nValIcms	:= (nVlrUnit / nTotIcms) * nSaldo
					nIcmsRet	:= (nVlrUnST / nTotIcmRet) * nSaldo					
					nBaseSol	:= (nBaseSol / nQtdEntr) * nSaldo//Base Icms St
	   				nBasePro	:= (nBasePro / nQtdEntr) * nSaldo//Base Icms Proprio
					aRet[1]		+= nValIcms
					aRet[2]		+= nIcmsRet
					aRet[3]		+= nBaseSol
					aRet[4]		+= nBasePro
				Endif 
				
			Else
				//�����������������������������������������������Ŀ
				//�Verifica a quantidade necessaria para o calculo�
				//�������������������������������������������������
				nQtdNec   := nSaldo - nQuant 
				
				//��������������������������������������������������������������������Ŀ
				//�Se a quantidade do item for maior que a necessaria, proporcionaliza �
				//����������������������������������������������������������������������
				If (cAliasSD1)->D1_QUANT > nQtdNec
					nPropor   := nQtdNec / (cAliasSD1)->D1_QUANT
				Else
					nPropor   := 1 
				EndIf 		                                                           
				
				//��������������������������������������Ŀ
				//�Aplica a proporcao na base e no valor �
				//����������������������������������������
				aRet[1]	+= nValIcms * nPropor
				aRet[2]	+= nIcmsRet * nPropor
				aRet[3]	+= nBaseSol * nPropor
				aRet[4]	+= nBasePro * nPropor
			Endif
			nQuant	+= (cAliasSD1)->D1_QUANT
		
			//����������������������������������������������������������������������������������Ŀ
			//�Armazena o item da nota fiscal que foi processado para composicao do estoque de ST�
			//������������������������������������������������������������������������������������
			cChave := (cAliasSD1)->D1_FILIAL+(cAliasSD1)->D1_DOC+(cAliasSD1)->D1_SERIE+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA+(cAliasSD1)->D1_COD+(cAliasSD1)->D1_ITEM
			nNfsProc := aScan(aNFsProc,{|x| x[1]+x[2]+x[3]+x[4]+x[5]+x[6]+x[7]==cChave})
			If nNfsProc == 0
				Aadd(aNFsProc,{(cAliasSD1)->D1_FILIAL,(cAliasSD1)->D1_DOC,(cAliasSD1)->D1_SERIE,(cAliasSD1)->D1_FORNECE,(cAliasSD1)->D1_LOJA,(cAliasSD1)->D1_COD,(cAliasSD1)->D1_ITEM,nBaseRet})
			Else
				aNFsProc[nNFsProc][8] := nBaseRet 
			Endif
		Endif
		#IFDEF TOP
			(cAliasSD1)->(dbSkip())
		#ELSE
			(cAliasSD1)->(dbSkip(-1))
		#ENDIF
	Enddo
	
	#IFDEF TOP
		dbSelectArea(cAliasSD1)
		dbCloseArea()
	#ELSE
		dbSelectArea(cAliasSD1)
		RetIndex(cAliasSd1)
		FErase(cInd+OrdBagExt())
	#ENDIF

Endif

RestArea(aArea)

Return(aRet)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RetMonta88�Autor  �Mary c. Hergert     � Data �  11/17/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Identifica se a nota fiscal de entrada pode ser considerada ���
���          �na geracao dos Registros 88 do Sintegra de MG               ���
�������������������������������������������������������������������������͹��
���Uso       �Mata940                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function RetMonta88(nICMSST,cSerie,cNF,cFornece,cLoja,cItem,cCod,lUsaSFT,nMargem,cCFOP)

// Identifica se a nota fiscal em questao nao e de frete
Local cCfoFret  := GetNewPar("MV_CFOFRET","") 

If lUsaSFT 
	SFT->(dbSetOrder(1))
Endif 

//������������������������������������������������������������������Ŀ
//�O registro devera ser gerado:                                     �
//�- quando na NF existir ICMS Retido                                �
//�- quando na NF nao existir ICMS Retido, mas no produto existir    � 
//�- a mergem do solidario na entrada                                �
//�- quando na NF existir a indicacao de que a operacao faz parte do �
//�  Regime Especial de ST, onde, mesmo sem ST, o item devera ser    �
//�  apresentado nos registros 88.                                   �
//��������������������������������������������������������������������
Return(	((nICMSST > 0) .Or.;
		(nICMSST == 0 .And. nMargem > 0) .Or.;
		(lUsaSFT .And. SFT->(dbSeek(xFilial("SFT")+"E"+cSerie+cNF+cFornece+cLoja+cItem+cCod)) .And. SFT->FT_RGESPST == "1")) .And.;
		!(cCFOP $ cCfoFret))

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �NfCompl   �Autor  �Mary C. Hergert     � Data �  11/17/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna os complementos das notas fiscais que foram selecio-���
���          �nadas para a geracao dos registros 88 do Sintegra MG        ���
�������������������������������������������������������������������������͹��
���Uso       �Mata940                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function NfCompl(cAliasSD1,nValIcms,nIcmsRet,dUltFec,nRetInd,aNFsProc,lUsaSFT,lRgEspSt,nMargem,nAlqRet,dDTSTMG,lRecalST,nBaseSol,nBasePro)

Local aChave	:= {"","","","",""}
Local cAlias	:= "SD1"
Local cDoc		:= (cAliasSD1)->D1_DOC
Local cSerie	:= (cAliasSD1)->D1_SERIE
Local cItem		:= (cAliasSD1)->D1_ITEM
Local cChave	:= ""
Local cCfoFret  := GetNewPar("MV_CFOFRET","") 
Local nBaseRet	:= 0  
Local nAuxRet	:= 0 
Local nNfsProc	:= 0
Local nItem		:= 0
Local nAuxIcms 	:= 0
Local nBAuxeSol := 0
Local nBAuxPro  := 0

#IFDEF TOP
	Local aStru 	:=	{}
	Local cQuery   	:=	""
	Local nX		:=	0                           
#ENDIF

Default aNFsProc := {}
Default nBaseSol := 0
Default nBasePro := 0

#IFDEF TOP
	cAlias	:= "ComplSD1"
	aStru	:= SD1->(dbStruct())
	cQuery	:= "SELECT D1_NFORI,D1_SERIORI,D1_ITEMORI,D1_VALICM,D1_ICMSRET,D1_BRICMS,D1_TOTAL,D1_CF,D1_TIPO,"
	cQuery	+= "D1_FILIAL,D1_DOC,D1_SERIE,D1_FORNECE,D1_LOJA,D1_COD,D1_ITEM,D1_DTDIGIT,D1_QUANT,D1_EMISSAO,"
	cQuery	+= "D1_BASEICM "
	cQuery	+= " FROM " + RetSqlName("SD1") + " "
	cQuery	+= "WHERE D1_FILIAL = '" + xFilial("SD1") + "' AND "
	cQuery	+= "D1_DTDIGIT < '" + Dtos(dUltFec) + "' AND "		
	cQuery	+= "D1_TIPO IN('P','I','C') AND "		
	cQuery	+= "D1_NFORI = '" + cDoc + "' AND "
	cQuery	+= "D1_SERIORI = '" + cSerie + "' AND "	
	cQuery	+= "D1_ITEMORI = '" + cItem + "' AND "
	cQuery	+= "D_E_L_E_T_= ' ' "
	cQuery	:= ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
	For nX := 1 To Len(aStru)
		If ( aStru[nX][2] <> "C" )
			TcSetField(cAlias,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
		EndIf
	Next nX
#ELSE
	dbSelectArea(cAlias)
	dbSetOrder(nRetInd+1)
	dbSeek(cDoc+cSerie+cItem)
#ENDIF

While !Eof() .And. (cAlias)->(D1_NFORI+D1_SERIORI+D1_ITEMORI) == (cDoc+cSerie+cItem)

	//���������������������������������������������������������������������������Ŀ
	//�Verifica se CFOP eh de frete para desconsiderar na geracao caso configurado�
	//�����������������������������������������������������������������������������
	If !Empty(cCfoFret) .And. (cAlias)->D1_CF $ cCfoFret
		(cAlias)->(dbSkip())
		Loop							
	Endif
	If RetMonta88((cAlias)->D1_ICMSRET,(cAlias)->D1_SERIE,;
				(cAlias)->D1_DOC,(cAlias)->D1_FORNECE,(cAlias)->D1_LOJA,;
				(cAlias)->D1_ITEM,(cAlias)->D1_COD,lUsaSFT,nMargem,(cAlias)->D1_CF)

		//�����������������������������������������������������������������������������������������Ŀ
		//�Ponto de entrada para retornar os valores de ICMS e ST nas notas de devolucao.           �
		//�Necessario ao fato de que, quando devolvo uma NF de saida sem calculo de ICMS            �
		//�ou ST, devera de alguma forma buscar os valores da nota de entrada da mercadoria vendida.�
		//�������������������������������������������������������������������������������������������
		nAuxIcms 	:= (cAlias)->D1_VALICM
		nAuxRet 	:= (cAlias)->D1_ICMSRET
		nBaseRet	:= (cAlias)->D1_BRICMS
		nBAuxeSol   := (cAlias)->D1_BRICMS
		nBAuxPro    := (cAlias)->D1_BASEICM
		If Existblock("A940STMG")
			aRetMG := Execblock("A940STMG",.F.,.F.,{cAlias,;
					(cAlias)->D1_FILIAL,;
					(cAlias)->D1_DOC,;
					(cAlias)->D1_SERIE,;
					(cAlias)->D1_FORNECE,;
					(cAlias)->D1_LOJA,;
					(cAlias)->D1_TIPO}) 
			If Len(aRetMG) >= 5
		    	nBaseRet 	:= aRetMG[02]
		        nAuxIcms	:= aRetMG[04]
		        nAuxRet		:= aRetMG[05]
		    Endif
	    Endif

		//��������������������������������������������������������������������������Ŀ
		//�Quando nao houve o calculo do ST, mas existe a margem de lucro na entrada,�
		//�o valor deve ser calculado para compor o registro.                        �
		//����������������������������������������������������������������������������
		If lRecalST .And. nIcmsRet == 0 .And. !Empty(dDTSTMG) .And. (cAliasSD1)->D1_DTDIGIT <= dDTSTMG .And. nMargem > 0
			aChave[01] := xFilial("SD1")
			aChave[02] := (cAlias)->D1_DOC
			aChave[03] := (cAlias)->D1_SERIE
			aChave[04] := (cAlias)->D1_FORNECE
			aChave[05] := (cAlias)->D1_LOJA
			nBaseRet := Ma950RecST(@nAuxRet,aChave,@nItem)
		Endif

		nValIcms	+= nAuxIcms					//ICMS PROPRIO
		nIcmsRet	+= nAuxRet					//ICMS ST
		nBaseSol    += nBAuxeSol                //BASE ST
		nBasePro    += nBAuxPro 				//BASE PROPRIO
		//����������������������������������������������������������������������������������Ŀ
		//�Armazena o item da nota fiscal que foi processado para composicao do estoque de ST�
		//������������������������������������������������������������������������������������
		cChave := (cAlias)->D1_FILIAL+(cAlias)->D1_DOC+(cAlias)->D1_SERIE+(cAlias)->D1_FORNECE+(cAlias)->D1_LOJA+(cAlias)->D1_COD+(cAlias)->D1_ITEM
		nNfsProc := aScan(aNFsProc,{|x| x[1]+x[2]+x[3]+x[4]+x[5]+x[6]+x[7]==cChave})
		If nNfsProc == 0
			Aadd(aNFsProc,{(cAliasSD1)->D1_FILIAL,(cAliasSD1)->D1_DOC,(cAliasSD1)->D1_SERIE,(cAliasSD1)->D1_FORNECE,(cAliasSD1)->D1_LOJA,(cAliasSD1)->D1_COD,(cAliasSD1)->D1_ITEM,nBaseRet})
		Else
			aNFsProc[nNFsProc][8] := nBaseRet 
		Endif
	Endif

	dbSelectArea(cAlias)
	dbSkip()
Enddo

#IFDEF TOP
	dbSelectArea(cAlias)
	dbCloseArea()
#ENDIF

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ma950RecST�Autor  �Mary c. Hergert     � Data �  11/17/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Recalcula o ICMS ST para as notas com Margem na entrada, mas���
���          �sem valor, para geracao dos registros 88 sintegra MG        ���
�������������������������������������������������������������������������͹��
���Uso       �Mata940                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Ma950RecST(nIcmsRet,aChave,nItem)

Local nBaseRet 	:= 0     

//������������������������������������������������������������������Ŀ
//�Inicializa as funcoes da MatxFis para recalculo e busca de valores�
//��������������������������������������������������������������������
If !(aChave[01]+aChave[02]+aChave[03]+aChave[04]+aChave[05] == xFilial("SF1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
	nItem := 1
	SF1->(DbSetOrder(1))
	SF1->(DbSeek(xFilial("SF1")+aChave[02]+aChave[03]+aChave[04]+aChave[05]))
	MaFisEnd()
	MaFisIniNf (1,0,,"SF1",.F.)
Else
	If nItem=0
		SF1->(DbSetOrder (1))
		SF1->(DbSeek(xFilial("SF1")+aChave[02]+aChave[03]+aChave[04]+aChave[05]))
		MaFisEnd()
		MaFisIniNf(1,0,,"SF1",.F.)
	Endif
	nItem++
EndIf

//�������������������������������������������������������������������������������������Ŀ
//�Recalcula os valores (ja que os mesmos nao foram calculados e gravados originalmente)�
//���������������������������������������������������������������������������������������
MaFisRecal("",nItem)
nBaseRet 	:= MaFisRet(nItem,"IT_BASESOL")
nIcmsRet	:= MaFisRet(nItem,"IT_VALSOL")

Return nBaseRet
Static Function RetCmpDel (cLinhaTxt, cDelimitador, nCmpDel)
Local	nX		:=	0
Local	nDel	:=	0
Local	cCampo	:=	""
//
For nX := 1 To Len (cLinhaTxt)
	cCampo	+=	SubStr (cLinhaTxt, nX, 1)
	If (cDelimitador$cCampo) .Or. (CHR (13)$cCampo)
		nDel++
		If (nDel==nCmpDel)
			cCampo:= substr(cCampo,1,len(cCampo)-1)
			Exit
		Else
			cCampo	:=	""
		EndIf
	EndIf
Next nX
Return (cCampo)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |TrbConso  �Autor  �Gustavo             � Data �  05/09/05   ���
�������������������������������������������������������������������������͹��
���Desc.     �Crio TRB conforme estrutura do registro contida no INI.     ���
���          �Esta rotina eh somente utilizado para inis que possuem a    ���
���          � clausula (CONSOLIDADO), para que seja processado o bloco   ���
���          � para o range de filiais apontado nesta clausula.           ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function TrbConso (nNewDel, nNivel, aStru, cChaveCons, aArqNew)
Local	lRet		:=	.T.
Local	nX			:=	0
Local	aStruXZ		:=	{}
Local	cChave		:=	""
Local	cCampo		:=	""
Local	cTipo		:=	""
Local	nTamanho	:=	0
Local	nDecimal	:=	0
Local	cNomeTrb	:=	""
//
If (nNewDel==1)
	cNomeTrb	:=	"XZ"+StrZero (nNivel, 1, 0)
	//
	For nX := 1 To Len (aStru[nNivel])
		cCampo		:=	AllTrim (aStru[nNivel][nX][1])
		cTipo		:=	AllTrim (aStru[nNivel][nX][2])
		nTamanho	:=	aStru[nNivel][nX][3]
		nDecimal	:=	aStru[nNivel][nX][4]
		aAdd (aStruXZ, {cCampo, cTipo, nTamanho, nDecimal})
		//
		If (AllTrim (cCampo)$cChaveCons)
			If ("N"$cTipo)
				cChave	+=	"StrZero ("+cCampo+","+StrZero (nTamanho, 3, 0)+","+StrZero (nDecimal, 2, 0)+")+"

			ElseIf ("C"$cTipo)
				cChave	+=	cCampo+"+"

			ElseIf ("D"$cTipo)
				cChave	+=	"DTOS ("+cCampo+")+"
			EndIf
		EndIf
	Next nX
	cChave	:=	Left (cChave, Len (cChave)-1)	//Tiro o mais do final
	//
	cArq	:=	CriaTrab (aStruXZ)
	DbUseArea (.T., __LocalDriver, cArq, cNomeTrb)
	IndRegua (cNomeTrb, cArq, cChave,,,Nil,.F.)
	//
	aArqNew	:=	{cNomeTrb, cArq}
Else
	dbSelectArea(aArqNew[1])
	dbCloseArea()
	Ferase(aArqNew[2]+GetDBExtension())
	Ferase(aArqNew[2]+OrdBagExt())
	//
	aArqNew	:=	{}
EndIf
Return (lRet)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |ConsoFil  �Autor  �Gustavo             � Data �  05/09/05   ���
�������������������������������������������������������������������������͹��
���Desc.     �Alimento o TRB gerado pela funcao TrbConso acumulando con-  ���
���          � a chave apontada na clausula (CONSOLIDADO).                ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ConsoFil (aArqNew, cChaveCons, nNivel, aStru, aConteudo, cCmpGrvCon)
Local	lRet	:=	.T.
Local	nCntFor		:=	0
Local	uConteudo
Local	cString		:=	""
Local	aGrava		:=	{}
Local	aAcumula	:=	{}
Local	cChave		:=	""

For nCntFor := 1 To Len (aStru[nNivel])
	uConteudo 	:= 	&(aConteudo[nNivel][nCntFor])
	cCampo		:=	AllTrim (aStru[nNivel][nCntFor][1])
	cTipo		:=	aStru[nNivel][nCntFor][2]
	//
	Do Case
	Case (cTipo == "N")
		If ( uConteudo == Nil )
			uConteudo := 0
		EndIf
		cString	:=	Str (uConteudo, aStru[nNivel][nCntFor][3], aStru[nNivel][nCntFor][4])

	Case (aStru[1][nCntFor][2]=="D")
		If (uConteudo==Nil)
			uConteudo := dDataBase
		EndIf
		cString	:=	PadR (Dtos (uConteudo), aStru[nNivel][nCntFor][3])

	Case (cTipo=="C")
		If (uConteudo==Nil)
			uConteudo := ""
		EndIf
		cString := PadR (uConteudo, aStru[nNivel][nCntFor][3])

	EndCase
	//�����������������������������������������������������������������������������������������Ŀ
	//�Verifico se o conteudo (cString) faz parte da chave de pesquisa pelo indice criado no TRB�
	//�������������������������������������������������������������������������������������������
	If (cCampo$cChaveCons)
		cChave	+=	cString
		aAdd (aGrava, {cCampo, uConteudo})
		//�����������������������������������������������������������������������������������������Ŀ
		//�Verifico se o conteudo mesmo nao fazendo parte do indice deve ser gravado no Reclock(.T.)�
		//�������������������������������������������������������������������������������������������
	ElseIf (cCampo$cCmpGrvCon)
		aAdd (aGrava, {cCampo, uConteudo})
		//�����������������������������������������������Ŀ
		//�Gravo os Reclock (.F.), acumuladores de valores�
		//�������������������������������������������������
	Else
		aAdd (aAcumula, {cCampo, uConteudo})
	EndIf
Next nCntFor
//
DbSelectArea (aArqNew[1])
//�������������������������������������Ŀ
//�Faco a inclusao no TRB conforme chave�
//���������������������������������������
If !(aArqNew[1])->(DbSeek(cChave))
	RecLock (aArqNew[1], .T.)
	For nCntFor := 1 To Len (aGrava)
		(aArqNew[1])->(FieldPut (&(aArqNew[1]+"->(FieldPos('"+aGrava[nCntFor][1]+"'))"), aGrava[nCntFor][2]))
	Next nCntFor
Else
	RecLock (aArqNew[1], .F.)
EndIf
For nCntFor := 1 To Len (aAcumula)
	(aArqNew[1])->&(aAcumula[nCntFor][1])	+=	aAcumula[nCntFor][2]
Next nCntFor
MsUnLock ()
Return (lRet)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |GeroConso �Autor  �Gustavo             � Data �  05/09/05   ���
�������������������������������������������������������������������������͹��
���Desc.     �Faco While no TRB criado e alimentado que servira de base   ���
���          � para a gravacao da funcao GrvBuffer com o TRB ja consolidado���
�������������������������������������������������������������������������͹��
���Parametros�nHandle -> Handle do txt para gravacao.                     ���
���          �aDelimit -> Flags para a inclusao dos delimitadores         ���
���          �aStru -> Estrutura do arquivo TRB criado.                   ���
���          �aArqNew -> Alias e Nome Fisico do TRB criado.               ���
���          �aAlias -> Alias apontado no INI para o bloco (SOMENTE UTI-  ���
���          � LIZADO PARA MOSTRAR O HELP NA TELA, POIS OS VALORES JA ESTAO���
���          � ACUMULADOS NO TRB CRIADO)                                  ���
���          �aConteudo -> Conteudo apontado no INI para o bloco (SOMENTE ���
���          � UTILIZADO PARA MOSTRAR O HELP NA TELA, POIS OS VALORES JA  ���
���          � ESTAO ACUMULADOS NO TRB CRIADO)                            ���
���          �aPosReg -> Conteudo apontado no INI para a clausula (POSREG)���
���          �aContReg -> Conteudo apontado no INI para a clausula (CONT) ���
���          �cMaskVlr -> Mascara padrao para os campos valores apontado  ���
���          � no INI atraves da clausula (MASKVLR)                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function GeroConso (nHAndle, aDelimit, aStru, aArqNew, aAlias, aConteudo, aPosReg, aContReg, cMaskVlr, lQuebralin)
Local	lRet	:=	.T.
//                     
DbSelectArea (aArqNew[1])
(aArqNew[1])->(DbGoTop ())
//
While !(aArqNew[1])->(Eof ())
	//
	GrvBuffer (nHAndle, aDelimit, aStru, aArqNew, aAlias, aConteudo, aPosReg, aContReg, cMaskVlr, lQuebralin)
	//
	(aArqNew[1])->(DbSkip ())
EndDo
Return (lRet)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |GeroConso �Autor  �Gustavo             � Data �  05/09/05   ���
�������������������������������������������������������������������������͹��
���Desc.     �Gravacao do registro do TRB no meio-magn�tico               ���
�������������������������������������������������������������������������͹��
���Parametros�nHandle -> Handle do txt para gravacao.                     ���
���          �aDelimit -> Flags para a inclusao dos delimitadores         ���
���          �aStru -> Estrutura do arquivo TRB criado.                   ���
���          �aArqNew -> Alias e Nome Fisico do TRB criado.               ���
���          �aAlias -> Alias apontado no INI para o bloco (SOMENTE UTI-  ���
���          � LIZADO PARA MOSTRAR O HELP NA TELA, POIS OS VALORES JA ESTAO���
���          � ACUMULADOS NO TRB CRIADO)                                  ���
���          �aConteudo -> Conteudo apontado no INI para o bloco (SOMENTE ���
���          � UTILIZADO PARA MOSTRAR O HELP NA TELA, POIS OS VALORES JA  ���
���          � ESTAO ACUMULADOS NO TRB CRIADO)                            ���
���          �aPosReg -> Conteudo apontado no INI para a clausula (POSREG)���
���          �aContReg -> Conteudo apontado no INI para a clausula (CONT) ���
���          �cMaskVlr -> Mascara padrao para os campos valores apontado  ���
���          � no INI atraves da clausula (MASKVLR)                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function GrvBuffer(nHAndle, aDelimit, aStru, aArqNew, aAlias, aConteudo, aPosReg, aContReg, cMaskVlr, lQuebralin)
Local	cBuffer		:=	""
Local	nCntFor		:=	0
Local	cDelimit	:=	AllTrim (aDelimit[1])
//         
If (Len (cDelimit)>1)
	If ("I"$SubStr (cDelimit, 2))
		cBuffer	+=	SubStr (cDelimit, 1, 1)
	EndIf
EndIf
//
For nCntFor := 1 To Len(aStru[1])
	cTipo		:=	ValType ((aArqNew[1])->&(aStru[1][nCntFor][1]))
	//
	bError := ErrorBlock({|e| Help(" ",1,"NORMAERRO3",,aAlias[1]+"->"+aStru[1][nCntFor][1]+"|"+aConteudo[1][nCntFor],3,1) })
	//
	BEGIN SEQUENCE
		uConteudo := (aArqNew[1])->&(aStru[1][nCntFor][1])
		Do Case
		Case (aStru[1][nCntFor][2]=="N")
			If ( uConteudo == Nil )
				uConteudo := 0
			EndIf
			//�������������������������������������������������������������������������������������`�
			//�Quando possuir mascara apontada no INI, utilizo-a no transform para gravacao no TXT.�
			//�������������������������������������������������������������������������������������`�
			If Empty (cMaskVlr) .Or. (aStru[1][nCntFor][4])==0
				uConteudo := NoRound (uConteudo*(10**(aStru[1][nCntFor][4])), aStru[1][nCntFor][4])

				If (!Empty (aDelimit[1]))
					cBuffer += Iif (Empty (AllTrim (Str (uConteudo,aStru[1][nCntFor][3]))), "", AllTrim (Str (uConteudo,aStru[1][nCntFor][3])))
				Else
					cBuffer += StrZero (uConteudo, aStru[1][nCntFor][3])
				EndIf
			Else
				cBuffer += AllTrim (Transform (uConteudo, cMaskVlr))
			EndIf

		Case (aStru[1][nCntFor][2]=="D")
			If (uConteudo==Nil)
				uConteudo := dDataBase
			EndIf
			cBuffer += PadR (Dtos (uConteudo), aStru[1][nCntFor][3])
		Case (aStru[1][nCntFor][2]=="C")
			If ( uConteudo == Nil )
				uConteudo := ""
			EndIf

			If (!Empty (aDelimit[1]))
				cBuffer += AllTrim (uConteudo)
			Else
				cBuffer += PadR (uConteudo, aStru[1][nCntFor][3])
			EndIf
		EndCase
	END SEQUENCE

	ErrorBlock(bError)

	If (Len (cDelimit)>1)
		If (nCntFor==Len (aStru[1]))
			If ("F"$SubStr (cDelimit, 2))
				cBuffer	+=	SubStr (cDelimit, 1, 1)
			EndIf
		Else
			If ("M"$SubStr (cDelimit, 2))
				cBuffer	+=	SubStr (cDelimit, 1, 1)
			EndIf
		EndIf
	EndIf

Next nCntFor
//������������������������������������������������������������������������Ŀ
//�Efetua a Gravacao da Linha                                              �
//��������������������������������������������������������������������������
If !Empty(cBuffer)
	FWrite(nHAndle,cBuffer+Iif(lQuebralin,Chr(13)+Chr(10),""))
	If ( Ferror()!=0 )
		Help(" ",1,"NORMAERRO4")
	EndIf
EndIf
aEval(aPosReg[1],{|x| &(x) })
//�����������������������Ŀ
//�Incrementa o contador  �
//�������������������������
aEval(aContReg[1],{|x| &(x) })
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �FsGrvTmp  � Autor �Eduardo Riera          � Data �07.09.2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de conversao de Array para arquivo temporario        ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1: Alias do arquivo temporario                          ���
���          �ExpA2: Array com a seguinte estrutura                       ���
���          �       [1] Registro                                         ���
���          �       [1][n] Campos do arquivo                             ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function FsGrvTmpA(cAlias,aArray)

Local aArea := GetArea()
Local nX    := 0
Local nY    := 0

dbSelectArea(cAlias)

For nX := 1 To Len(aArray)
	RecLock(cAlias,.T.)
	For nY := 1 To Len(aArray[nX])
		FieldPut(nY,aArray[nX][nY])
	Next nY
	MsUnLock()	
Next nX

RestArea(aArea)
Return(.T.)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �FsDateConv� Autor �Eduardo Riera          � Data �20.10.2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de conversao de data para string em varios formatos  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpC1: String                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpD1: Alias do arquivo temporario                          ���
���          �ExpC2: Formato onde:                                        ���
���          �       DD = Dia                                             ���
���          �       MM = Mes                                             ���
���          �       YYYY ou YY = Ano                                     ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function FsDateConvA(dData,cMasc)

Local cDia    := ""
Local cMes    := ""
Local cAno    := ""
Local cData   := Dtos(dData)
Local cResult := ""
Local cAux    := ""

DEFAULT cMasc := "DDMMYYYY"

cDia := SubStr(cData,7,2)
cMes := SubStr(cData,5,2)
cAno := SubStr(cData,1,4)

While !Empty(cMasc)
	cAux := SubStr(cMasc,1,2)
	Do Case
		Case cAux == "DD"
			cResult += cDia
		Case cAux == "MM"
			cResult += cMes
		Case cAux == "YY"
			If SubStr(cMasc,1,4) == "YYYY"
				cResult += cAno
				cMasc := SubStr(cMasc,3)
			Else
				cResult += SubStr(cAno,3)
			EndIf			
	EndCase
	cMasc := SubStr(cMasc,3)
EndDo
Return(cResult)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �FsLoadTxt � Autor �Eduardo Riera          � Data �24.10.2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de leitura de arquivo texto para anexar ao layout    ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExC1: Arquivo texto                                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1: Nome do arquivo texto com path                       ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function FsLoadTXTA(cFileImp)

Local cTexto     := ""
Local cNewFile   := ""
Local cExt       := "" 
Local cStartPath := GetSrvProfString("StartPath","")
cStartPath := StrTran(cStartPath,"/","\")
cStartPath +=If(Right(cStartPath,1)=="\","","\")

CpyT2S(cFileImp,cStartPath)
SplitPath(cFileImp,/*cDrive*/,/*cPath*/, @cNewFile,cExt)
cNewFile := cNewFile+cExt

FT_FUse(cNewFile)
FT_FGotop()
While ( !FT_FEof() )
	cTexto += FT_FREADLN()
	FT_FSkip()
EndDo
FT_FUse()
Return(cTexto)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �RetNf 	� Autor �Andressa Fagundes      � Data �19.12.2006���
�������������������������������������������������������������������������Ĵ��
���Descri�ao �Funcao para retornar a quantidade de caracteres de acordo   ���
���          �com o layout especificado(Usado para numero da Nota Fiscal) ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExC1: Arquivo texto                                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros�cCampo: Nome do campo            				    	      ���
���          �nDig:	Qtd de digitos de acordo com o layout 		          ���
���          �cTipo: Tipo Caracter(C) ou Numerico(N) conforme layout      ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/ 
User Function RetNfA(cCampo,nDig,cTipo)

Local 	cRet	:=	""

Default nDig	:= TamSX3("F2_DOC")[1]
Default cCampo	:= ""
Default cTipo	:= ""

If cTipo = "N"
	cRet	:= Right(Replicate("0",nDig-Len(Alltrim(cCampo)))+Alltrim(cCampo),nDig)
Else
	cRet	:= Right(Alltrim(cCampo),nDig) //usar nos casos que o tamanho e menor que 9
Endif	

Return (cRet)
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �MontaXML 	� Autor �Mary C. Hergert        � Data �03/05/2007���
�������������������������������������������������������������������������Ĵ��
���Descri�ao �Funcao para retornar a linha em formato XML (tags)          ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpC1 : linha em xml                                        ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1 : Tag a ser apresentada   				    	      ���
���          �ExpC2 : Campo a ser apresentado na Tag (conteudo)           ���
���          �ExpC3 : Tipo do campo                                       ���
���          �ExpN4 : Tamanho do campo                                    ���
���          �ExpN5 : Decimais do campo                                   ���
���          �ExpC6 : Mascara do campo                                    ���
���          �ExpN7 : Deslocamento inicial da tag (identacao)             ���
���          �ExpL8 : Se apresenta a Tag inicial <>                       ���
���          �ExpL9 : Se apresenta a Tag final </>                        ���
���          �ExpLA : Se inclui a quebra de linha chr(13) + chr(10)       ���
���          �ExpLB : Atributo de TAG                                     ���
���          �ExpLC : Se apresenta Tag caracter com acentos               ���
���          �ExpLD : Se � Diopsfin                                       ���
���          �ExpLE : Se considera case sensitive                         ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/ 
User Function MontaXMLA(cTag,cCampo,cTipo,nTam,nDec,cMask,nDesloc,lTagIn,lTagFim,lQuebra,cAtrib,lAcento,lDiopsfin,lCasSens)

Local cXML 		:= ""
Local cAuxCampo := ""
Local cAuxTam	:= ""
Local cAuxDec	:= ""
Local cDesloc	:= ""
Local cTagIni	:= ""
Local cTagFim	:= "" 

Local nAt:=0

Default cTipo	  := "C"
Default nTam	  := 0
Default	nDec	  := 0   
Default	cMask	  := ""
Default nDesloc	  := 0
Default	lTagIn	  := .T.
Default	lTagFim	  := .T.
Default	lQuebra	  := .T.
Default cCampo	  := ""
Default	cAtrib	  := ""
Default lAcento	  := .F.
Default lDiopsfin := .F.
Default lCasSens  := .F.

cAuxTam	:= Replicate("9",nTam)
cAuxDec	:= Replicate("9",nDec)
cDesloc	:= Space(nDesloc)

//�������������Ŀ
//�Monta as tags�
//���������������
If lTagIn
	cTagIni	:= "<" + Alltrim(cTag)
	If !Empty(cAtrib)
		cTagIni	+= " " + Alltrim(cAtrib)
	EndIf
	cTagIni	+= ">"
Endif                                   
If lTagFim                           
	nAt:=AT(' ',Alltrim(cTag))
	If cPaisLoc == "EQU" .And. nAt > 0 
	  	cTagFim	:= "</" + Substr(Alltrim(cTag),1,nAt-1) + ">"		
		//cTagFim	:= "</" + Alltrim(cTag) + ">"
	Else
		cTagFim	:= "</" + Alltrim(cTag) + ">"		
	EndIf
Endif                                       

cAuxCampo := Alltrim(cCampo)

//�����������������������������Ŀ
//�Remove os acentos das strings�
//�������������������������������
If cTipo == "C" .And. !lAcento 
	If lCasSens
		cAuxCampo := Alltrim(NoAcento(AnsiToOem(AllTrim(cAuxCampo))))
	Else
		cAuxCampo := Alltrim(Upper(NoAcento(AnsiToOem(AllTrim(cAuxCampo)))))
	EndIf
Endif
//��������������������������������������������������������������
//�Monta a mascara passada como parametro ou mascara padrao    �
//��������������������������������������������������������������
If !Empty(cMask)
	cAuxCampo := Transform(cCampo,cMask)
Else
	If cTipo == "N"                      
		cAuxCampo := Transform(cCampo,"@E"+cAuxTam+"."+cAuxDec)
	Endif
	If cTipo == "D"
		cAuxCampo := dToS(cCampo)
	Endif
Endif
        
cAuxCampo := Alltrim(cAuxCampo)

//����������������������������������������������������������������������������������������������������Ŀ
//�Monta a linha XML: deslocamento inicial da linha + Tag Inicial + campo a ser apresentado + Tag Final�
//������������������������������������������������������������������������������������������������������
cXML := cDesloc + cTagIni + StrTran(cAuxCampo,"&","&amp;") + cTagFim

//�����������������������������������Ŀ
//�Insere o <enter> para quebrar linha�
//�������������������������������������
If lQuebra 
	cXML  	:= cXML + Chr(13) + Chr(10)
Endif

If lDiopsfin
	cXMLStatic	+=	cAuxCampo
EndIf

Return cXML            

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �HashXmlI  �Autor  �                    � Data �  25/11/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Inicializa a variavel para acumular as informa��es do diops ���
�������������������������������������������������������������������������͹��
���Uso       �Diopsfin.ini                                                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function HashXmlIA()

cXMLStatic := ""
	
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �HashXmlf  �Autor  �                    � Data �  25/11/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �retorna a variavel com a conteudo para calculo md5 diops    ���
�������������������������������������������������������������������������͹��
���Uso       �Diopsfin.ini                                                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function HashXmlFA()

Local HashCont := ""
	
HashCont := Alltrim(cXMLStatic)

Return HashCont

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �FormDate  �Autor  �                    � Data �  31/05/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Converte data no formato dd/mm/aaaa                         ���
�������������������������������������������������������������������������͹��
���Parametros�dData  -> Data a ser convertida (D)                         ���
���          �lBarra -> Indica se a string retorna com barra (DEFAULT = T)���
�������������������������������������������������������������������������͹��
���Uso       �MATA950                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function FormDateA(dData,lBarra)
DEFAULT lBarra := .T.
Return StrZero(Day(dData),2)+ IIF(lBarra,"/","") + StrZero(Month(dData),2)+ IIF(lBarra,"/","") + StrZero(Year(dData),4)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FsProcesso�Autor  �Mary C. Hergert     � Data �  07/14/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Chama as funcoes de saldo em processo do livro P7 para que  ���
���          �o registro 74 seja um espelho do livro impresso.            ���
�������������������������������������������������������������������������͹��
���Uso       �Sintegra                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FsProcesso(aProd,dDtInv,aNCM,aProcesso)

Local aArqTemp		:= {}

Local cArqTemp 		:= "" 
Local cArqTemp2		:= "" 
Local cAlias		:= "PRS"

Local nTpProcesso 	:= SuperGetMV("MV_R460PRC",.F.,1)

If Len(aProd) >= 11
	If Select(cAlias)>0
		DbSelectArea(cAlias)
		DbCloseArea()
	EndIf
	//��������������������������Ŀ
	//� Cria Arquivo Temporario  �
	//� SITUACAO: 2 = PROCESSO   �
	//����������������������������
	AADD(aArqTemp,{"FILIAL"	    ,"C",02,0})
	AADD(aArqTemp,{"SITUACAO"	,"C",01,0})
	AADD(aArqTemp,{"TIPO"		,"C",02,0})
	AADD(aArqTemp,{"POSIPI"		,"C",TamSX3("B1_POSIPI")[1],0})
	AADD(aArqTemp,{"PRODUTO"	,"C",TamSX3("B1_COD")[1],0})
	AADD(aArqTemp,{"DESCRICAO"	,"C",35,0})
	AADD(aArqTemp,{"UM"			,"C",TamSX3("B1_UM")[1],0})
	AADD(aArqTemp,{"QUANTIDADE"	,"N",14,If(TamSX3("B2_QFIM")[2] > 4,3,TamSX3("B2_QFIM")[2])})
	AADD(aArqTemp,{"VALOR_UNIT"	,"N",21,TamSX3("B2_CM1")[2]})
	AADD(aArqTemp,{"TOTAL"		,"N",21,TamSX3("B2_CM1")[2]})
	AADD(aArqTemp,{"ALIQ"	    ,"N",5,2})
	AADD(aArqTemp,{"SITTRIB"	,"C",4,0})
	
	cArqTemp :=CriaTrab(aArqTemp)
	dbUseArea(.T.,__LocalDriver,cArqTemp,cAlias)
	IndRegua(cAlias,cArqTemp,"SITUACAO+TIPO+STR(ALIQ,5,2)+PRODUTO")
	dbClearIndex()
	
	cArqTemp2 := CriaTrab(Nil,.F.)
	IndRegua(cAlias,cArqTemp2,"PRODUTO+SITUACAO")
	dbClearIndex()
	
	dbSetIndex(cArqTemp+OrdBagExt())
	dbSetIndex(cArqTemp2+OrdBagExt())
	dbSetOrder(1)

	//������������������������������������������������������������������Ŀ
	//�aProd[01] = Produto de                                            �
	//�aProd[02] = Produto ate                                           �
	//�aProd[03] = Armazem de                                            �
	//�aProd[04] = Armazem ate                                           �
	//�aProd[05] = Saldo Negativo                                        �
	//�aProd[06] = Saldo Zerado                                          �
	//�aProd[07] = Saldo Terceiros (Sim, Nao, de terceiros, em terceiros)�
	//�aProd[08] = Custo Zerado                                          �
	//�aProd[09] = Em processo                                           �
	//�aProd[10] = Data de Fechamento                                    �
	//�aProd[11] = MOD no Processo                                       �
	//��������������������������������������������������������������������
	lSaldProcess	:= (aProd[09] == 1)
	lSaldTerceir	:= (aProd[07] <> 2)
	cAlmoxIni		:= Iif(aProd[03]=="**",Space(02),aProd[03])
	cAlmoxFim		:= Iif(aProd[04]=="**",Space(02),aProd[04])
	cProdIni		:= aProd[01]
	cProdFim		:= aProd[02]
	lListProdNeg	:= aProd[05]
	lListProdZer	:= aProd[06]
	dDtFech	    	:= aProd[10]
	lListCustZer	:= (aProd[08]==1)   
	lEnd			:= .F.
	lFiscal 		:= .T.
	nIndSB6	   		:= 0
	cIndSB6    		:= ""
	cKeyQbr	   		:= ""
	cPerg      		:= "MTR460"
	aSaldoTerD 		:= {}
	aSaldoTerT 		:= {}
	nDecVal    		:= TamSX3("B2_CM1")[2] // Retorna o numero de decimais usado no SX3
	nPagIni	    	:= 0
	nQtdPag	    	:= 0
	cNrLivro    	:= ""
	lLivro	    	:= .T.
	lDescrNormal	:= .T.
	lListCustMed	:= .T.
	lCalcProcDt 	:= .T.
	lQuebraST   	:= .F.
	nQuebraAliq		:= 2
	                   
	//���������������������������������������������������������������������������Ŀ
	//� Processa Saldo Em Processo TIPO 2 - SALDO EM PROCESSO                     �
	//�����������������������������������������������������������������������������			
	If nTpProcesso == 1
		R460EmProcesso(@lEnd,cAlias,.T.,aProd,@aNCM,,,nTpProcesso)  
	Else
		R460AnProcesso(@lEnd,cAlias,.T.,aProd,@aNCM)
	EndIf	
	        
	aProcesso := {cArqTemp,cAlias}
Endif      

Return(cAlias)
	
/*����������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������Ŀ��
���Fun�ao    �IESubTrib � Autor � Liber De Esteban			   � Data � 04/08/09 ���
��������������������������������������������������������������������������������Ĵ��
���Descri�ao � Retorna a inscricao estadual (se houver) do estado onde ocorreu   ���
���          �  a retencao, buscando no MV_SUBTRIB (e demais MV_SUBTRI's)        ���
��������������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAFIS                                                           ���
���������������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������������
����������������������������������������������������������������������������������*/
User Function IESubTribA(cUf,lDifal)
	
	Local cMVSUBTRIB	:= ""
	Local cInscr		:= ""
	Local nPosI			:= 0
	Local nPosF			:= 0
	Local aAliasSX6		:= SX6->(GetArea())
	
	//Tratamento para Estados que possuem IE exclusiva para Difal e n�o se aplicam ao ST
	Default lDifal:= .F.
If lDifal .And. !AliasInDic("F0L")
	lDifal:= .F.
endif
	
If (AllTrim(SuperGetMv("MV_SUBTRIB"))=="" .Or. lDifal) .And. FindFunction("GETSUBTRIB") 
	cInscr := GetSubTrib(cUF,lDifal)
Else
	DbSelectArea ("SX6")
	SX6->(DbSetOrder (1))
	
	If SX6->(DbSeek (cFilAnt+"MV_SUBTRI"))
		//Verifica o(s) MV_SUBTRIB(s) somente da filial corrente
		Do While !SX6->(Eof ()) .And. ("MV_SUBTRI"$SX6->X6_VAR) .And. (cFilAnt==SX6->X6_FIL)
			If !Empty(SX6->X6_CONTEUD)
				cMVSUBTRIB += "/"+AllTrim (SX6->X6_CONTEUD)
			EndIf
			SX6->(DbSkip ())
		EndDo   
		If At (cUf,cMVSUBTRIB) > 0
			nPosI	:=	At (cUf,cMVSUBTRIB)+2
			nPosF	:=	At ("/", SubStr (cMVSUBTRIB, nPosI))-1
			nPosF	:=	IIf(nPosF<=0,len(cMVSUBTRIB),nPosF)
			cInscr	:=	SubStr(cMVSUBTRIB,nPosI,nPosF)
		EndIf
	EndIf	
	
	If SX6->(DbSeek(Space(FWSizeFilial())+"MV_SUBTRI"))
		//Verifica o(s) MV_SUBTRIB(s) para todas as filiais
		Do While !SX6->(Eof ()) .And. ("MV_SUBTRI"$SX6->X6_VAR) .And. Empty(SX6->X6_FIL)
			If !Empty(SX6->X6_CONTEUD)
				cMVSUBTRIB += "/"+AllTrim (SX6->X6_CONTEUD)
			EndIf
			SX6->(DbSkip ())
		EndDo     
		If At (cUf,cMVSUBTRIB) > 0
			nPosI	:=	At (cUf,cMVSUBTRIB)+2
			nPosF	:=	At ("/", SubStr (cMVSUBTRIB, nPosI))-1
			nPosF	:=	IIf(nPosF<=0,len(cMVSUBTRIB),nPosF)
			cInscr	:=	SubStr(cMVSUBTRIB,nPosI,nPosF)
		EndIf	
	EndIf	
EndIf

	
	RestArea(aAliasSX6)
Return cInscr
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MATA950   �Autor  �Fabricio Bernardo   � Data �  18/11/09   ���
�������������������������������������������������������������������������͹��
���Desc.     � Fun��o para buscar no par�metro "MV_TMSSQTR" pr�ximo       ���
���          � sequencial  de transmi��o dispon�vel.                      ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function SequenTranA(lGrava)

Local 	nSequen 	:= 0
Local 	cUf 		:= AllTrim(Substr(MV_PAR03, (len(AllTrim(MV_PAR03))-1), 2))
Local 	aAreaSX6 	:= SX6->(GetArea())
Local 	cSequeTr	:= Upper(SuperGetMv("MV_TMSSQTR", .F., ""))

Default lGrava		:= .F.

PutHelp("PMATA9501",{"Par�metro MV_TMSSQTR n�o preenchido corretamente."},{""},{""},.F.)

If (ValType(cSequeTr) != "L")
	If cSequeTr != " " .And. (AllTrim(Substr(Upper(MV_PAR03),1,3)) == "EDI")
		//������������������������������������������������������������������������Ŀ
		//� Pesquisa a pr�xima sequencia dispon�vel para o estado selecionado.     �
		//��������������������������������������������������������������������������
		nPosIni := AT(cUf, cSequeTr)
		nPosini += 3
		nSequen := Substr(cSequeTr, nPosini, 7)
		
		If (lGrava)
			SX6->(DbSetOrder(1))
			If SX6->(DbSeek( xFilial("SX6") + "MV_TMSSQTR" ))
				nPosIni 	:= AT(nSequen, cSequeTr)
				nSequen		:= Soma1(nSequen)
				cSequeTr 	:= Stuff(cSequeTr, nPosIni, 7, nSequen)
				PutMV("MV_TMSSQTR",cSequeTr)
			EndIf
		EndIf
		
	Else
		Help(" ", 1, "PMATA9501") // Par�metro MV_TMSSQTR n�o preenchido corretamente.
		Return Nil
	EndIf
EndIf

RestArea(aAreaSX6)
Return ( Iif(!lGrava, nSequen, NIL ))

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MATA950   �Autor  �V.Raspa             � Data �  22.Jun.10  ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao para validar o cabecalho da NF X Itens da NF conf.  ���
���          � condicao recebida via argumento da funcao                  ���
�������������������������������������������������������������������������͹��
���Uso       � NOR08655.INI                                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function FsValidNFA( nTipo, cDoc, cSerie, cClieFor, cLoja, cRegistro )

Local lRet := .F.
Local cSelect := ""
Local cFrom := ""
Local cWhere := ""
Local cAlias := ""

//--Valores para nTipo:
//-- 1 - Entrada: Considera Cabecalho X Itens de notas fiscais de entrada
//-- 2 - Saida: Considera Cabecalho X Itens de notas fiscais de saida
	
cSelect += "COUNT(SFT.FT_NFISCAL) QTDE "

cFrom := RetSqlName("SFT") + " SFT "

cWhere += "SFT.FT_FILIAL = '" + xFilial("SFT") + "' AND "

If nTipo == 1
	cWhere += "SFT.FT_TIPOMOV = '" + "E" + "' AND "
Else
	cWhere += "SFT.FT_TIPOMOV = '" + "S" + "' AND "
EndIf			                     

cWhere += "SFT.FT_NFISCAL = '" + cDoc + "' AND "
cWhere += "SFT.FT_SERIE = '" + cSerie + "' AND "
cWhere += "SFT.FT_CLIEFOR = '" + cClieFor + "' AND "					      
cWhere += "SFT.FT_LOJA = '" + cLoja + "' AND "

Do Case
	Case cRegistro == "4.11.1"
		cWhere += "SFT.FT_TIPO <> 'S' AND "
	Case cRegistro == "4.11.2"
		cWhere += "SFT.FT_TIPO = 'S' AND "
		cWhere += "SFT.FT_VALPIS > 0 AND "
		cWhere += "SFT.FT_VALCOF > 0 AND "	
		cWhere += "SFT.FT_VALCSL > 0 AND "		
	Case cRegistro == "4.11.5"
		cWhere += "SFT.FT_TIPO = 'S' AND "
		cWhere += "SFT.FT_VALPIS > 0 AND "
		cWhere += "SFT.FT_VALCOF > 0 AND "	
		cWhere += "SFT.FT_VALCSL > 0 AND "		
EndCase

cWhere += "SFT.D_E_L_E_T_ = '' "  

// Ajustando vari�veis para a execu��o do BeginSQL
cSelect := "%" + cSelect + "%"
cFrom := "%" + cFrom + "%"
cWhere := "%" + cWhere + "%" 

If TcSrvType()<>"AS/400"	 

	cAlias := GetNextAlias()  
	     	           
	BeginSql Alias cAlias
		
		SELECT
			%Exp:cSelect% 

		FROM 
			%Exp:cFrom%			
		
		WHERE
			%Exp:cWhere%				
							 				  				  		            
	EndSql
	
EndIf

DbSelectArea(cAlias)

lRet := (cAlias)->QTDE > 0

(cAlias)->(dbCloseArea())

Return(lRet)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �SerieConv �Autor  � William P. Alves   � Data �  28/09/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Converte a s�rie para que seja gerada de acordo com leiaute.���
�������������������������������������������������������������������������͹��
���Uso       �ISSITA.INI                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function SerieConvA(cSerie)

Local cTiposDoc	:= Alltrim(GetNewPar("MV_SERCONV",""))
Local nPosSign	:= 0
Local cSerTranf	:= ""

Default cSerie	:= ""

	If !Empty(cTiposDoc)
		nPosSign:=At("=",cTiposDoc)
		While nPosSign <= Len(cTiposDoc) .And. nPosSign<>0
			If Substr(cTiposDoc,At("=",cTiposDoc)+1,3)==Substr(cSerie,1,3)
				cSerTranf := Substr(cTiposDoc,At("=",cTiposDoc)-3,3)
			EndIf
		cTiposDoc := Substr(cTiposDoc,nPosSign+1,Len(cTiposDoc))
		nPosSign:=At("=",cTiposDoc)
		Enddo
	EndIf 	
			     
Return(cSerTranf)
/*
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������ͻ��
���Funcao    �NferioSer �Autor  � Marcio Nunes       � Data �  28/06/12       ���
�����������������������������������������������������������������������������͹��
���Desc.     �Registro Tipo 40 - Declara��o de Notas Convencionais Recebidas. ���
���			  NOTA FISCAL DE SERVICO ELETRONICA (NFS-e RIO)				      ���
�����������������������������������������������������������������������������͹��
���Uso       �NFERIO.INI                                                      ���
�����������������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
*/   


/*
Codigos referentes a tabela da Receita, para o NFS-E RIO do Registro 40
 "01" Nota Fiscal de Servi�o			
 "02" Nota Fiscal Fatura de Servi�o			
 "03" Bilhete de Ingresso			
 "04" Nota Fiscal Simplificada de Servi�o			
 "05" Nota Fiscal de Entrada			
 "06" Nota Fiscal Remessa de Material e Equipamento			
 "07" Cupom de M�quina Registradora			
 "08" Carn� de Pagamento			
 "09" Bilhete Eletr�nico de Ingressos			
 "10" Nota Fiscal de Entrada e Servi�o			
 "11" Rol de Lavanderia			
 "12" Nota de Hospedagem			
 "13" Cupom de Estacionamento			
 "14" Nota Fiscal Conjunta Estadual			
 "15" Nota Fiscal Conjunta Federal			
 "16" Conhecimento de Transporte Conjunto Estadual			
 "17" Emissor de Cupons Fiscais - ECF			
 "18" Recibo			
 "19" Nota Fiscal Sa�da de Mercadoria			
 "20" Nota Fiscal de Estacionamento
 "99" Fora do Pa�s	
 
  
 Codigos referentes a tabela da Receita, para o NFS-E Duque de Caxias do Registro 40
 01 - Nota Fiscal 
 02 - Recibo 
 03 - Fatura 
 04 - Nota de Simples Remessa 
 05 - Nota de Devolu��o		 	
*/

User Function NferioSerA(cEspecie)

Local aSeries 	:= {}
Local nX		:= 0
Local cSeries	:= "00"

Default cEspecie := ""

If !Empty(Alltrim(cEspecie))
	aSeries := Separa(GetNewPar("MV_ESPNRIO",""),";")
	nX := aScan(aSeries,{|x| SubStr(x,4,5) ==Alltrim(cEspecie)})
	If nX > 0
		cSeries := SubStr(aSeries[nx],1,2)
	EndIf
	
EndIf
	      
Return (cSeries)

//-------------------------------------------------------------------
/*/{Protheus.doc} SpoolGetMask
Funcao que retorna o tamanho da mascara a ser utilizada na impressao dos
campos numericos nas funcionalidades do Spool.
@param	nLen	-> Tamanho do campo
		nDec	-> Numero de casas decimais
@return	nRet	-> Tamanho a ser considerado para composicao da mascara
@author	Luccas Curcio
@since	18/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
User Function SpoolGetMaskA( nLen , nDec )
Local	nAddDec	:=	GetNewPar( "MV_MASKDEC" , 1 )
Local	nRet	:=	0

If nAddDec == 1
	nRet := nLen
Elseif nAddDec == 2
	nRet := nLen + nDec
Elseif nAddDec == 3
	nRet := nLen - nDec
Endif

Return nRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �435NfServ �Autor  �Marcio Nunes        � Data �  17/03/2014 ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna o os valores das Notas de ISS aglutinado os         ���
���          �registros da tabela SF3.                                    ���
�������������������������������������������������������������������������͹��
���Uso       �Norma086                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function N435NfSA(aControle,nTipo)



#IFDEF TOP
	Local aStru 	:=	{}
	Local cQuery   	:=	""
	Local nX		:=	0
	                           
#ENDIF
	Default nTipo	:=  1 
	
	If Len(aControle)==2
		aadd(aControle,aControle[1])
	EndIf
	
If nTipo == 1
	
	#IFDEF TOP
		
		aStru  := (aControle[1])->(dbStruct())
		cQuery	:= "SELECT DISTINCT A.F3_VALCONT,A.F3_BASEICM,SF3.F3_NFISCAL,SF3.F3_FILIAL,SF3.F3_ENTRADA,SF3.F3_TIPO,"	
		cQuery	+= "SF3.F3_CFO,SF3.F3_CLIEFOR,SF3.F3_LOJA,SF3.F3_SERIE,SF3.F3_TIPO,SF3.F3_DTCANC "		
		cQuery	+= "FROM " + RetSqlName(aControle[1]) + " SF3 "
		cQuery  += "LEFT JOIN (SELECT F3_NFISCAL,F3_SERIE,F3_CLIEFOR,F3_LOJA,SUM(F3_VALCONT) F3_VALCONT,SUM(F3_BASEICM) F3_BASEICM "
		cQuery	+= "FROM " + RetSqlName(aControle[1]) + " WHERE F3_FILIAL = '" + xFilial(aControle[1]) + "' AND F3_ENTRADA>='"+ DTOS(MV_PAR01) +"' AND F3_ENTRADA<='"+ DTOS(MV_PAR02) +"' AND F3_TIPO='S' AND "
		cQuery	+=  RetSqlName(aControle[1])+".D_E_L_E_T_=' ' "
		cQuery	+= "GROUP BY F3_NFISCAL, F3_SERIE ,F3_CLIEFOR ,F3_LOJA) A "		
		cQuery	+= "ON "
		cQuery	+= "A.F3_NFISCAL = SF3.F3_NFISCAL AND "	
		cQuery	+= "A.F3_SERIE = SF3.F3_SERIE AND "
		cQuery  += "A.F3_CLIEFOR = SF3.F3_CLIEFOR AND "
		cQuery  += "A.F3_LOJA = SF3.F3_LOJA "
		cQuery  +=	"WHERE  F3_FILIAL='"+ xFilial(aControle[1]) +"' AND F3_ENTRADA>='"+ DTOS(MV_PAR01) +"' AND F3_ENTRADA<='"+ DTOS(MV_PAR02) +"' AND F3_TIPO='S' "
		cQuery	:= ChangeQuery(cQuery)

		If Select(aControle[3])<>0
			(aControle[3])->(dbCloseArea())
		EndIf

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),aControle[3]) 
		For nX := 1 To Len(aStru)
			If ( aStru[nX][2] <> "C" )
				TcSetField(aControle[3],aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
			EndIf
		Next nX
	#ENDIF
Else
	dbSelectArea(aControle[3])
	dbCloseArea()
	dbSelectArea(aControle[1])
EndIf

Return(.T.) 

//-------------------------------------------------------------------
/*/{Protheus.doc} RetNumStr
Funcao que retorna valores numericos e strings de um texto separado.
@param	cTexto	-> Texto para separar os tipos de caracteres
@return	aRet	-> Array que possui duas posicoes:
                   1 - Conteudos Caracteres
                   2 - Conteudos numericos
@author	Leonardo Kichitaro
/*/
//-------------------------------------------------------------------
Static Function RetNumStr(cTexto)

Local nX		:= 0
Local aRet		:= {"",""}
Local cVar		:= ""
Local cVarFil	:= AllTrim(cTexto)
Local nTamTxt	:= Len(cVarFil)

For nX := 1 To nTamTxt
	cVar	:= SubStr(cVarFil,1,1)
	cVarFil	:= SubStr(cVarFil,2)
	If Empty(cVar)
		Loop
	ElseIf cVar <> "0" .And. Val(cVar) = 0
		aRet[1] += cVar
	Else
		aRet[2] += cVar
	EndIf
Next

Return aRet

//-------------------------------------------------------------------
/*/ {Protheus.doc} AjustaSX1
Atualiza dicionario (Pergunte)
/*/
//-------------------------------------------------------------------
Static Function AjustaSX1()
Local aArea	:= GetArea()
Local aHelpPor := {}
Local cPerg	:= 'MTA950'+ Space(Len(SX1->X1_GRUPO)-6)
SX1->(dbSetOrder(1))
If SX1->(dbSeek(cPerg+'06',.F.)) .and. !SX1->X1_TIPO == 'N'
	RecLock('SX1',.F.)
	SX1->X1_TIPO	:= 'N'
	msUnlock()
EndIf 

// PutSX1(cGrupo  ,cOrdem,cPergunt              ,cPerSpa,cPerEng,cVar    ,cTipo,nTamanho            ,nDecimal,nPresel,cGSC,cValid,cF3   ,cGrpSxg,cPyme,cVar01    ,cDef01,cDefSpa1,cDefEng1,cCnt01,cDef02 ,cDefSpa2,cDefEng2,cDef03,cDefSpa3,cDefEng3,cDef04,cDefSpa4,cDefEng4,cDef05,cDefSpa5,cDefEng5,aHelpPor)
aHelpPor := {"Indica se deve aglutinar as informa","��es das filiais selecionadas em um","�nico arquivo ou gerar os dados das","filiais separados por arquivos."}
PutSx1("MTA950","07","Aglutina Obriga��o?","","","MV_CH7","N"  ,1,0 ,2      ,"C" ,""    ,""    ,""    ,"S"   ,"mv_par07","Sim"    ,""      ,""      ,""    ,"N�o"     ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,""    ,""      ,""      ,aHelpPor)

RestArea(aArea)
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} A95088MGNf
Fun��o que calcula valor do ICMS ST a ser restitu�do para Minas Gerias
na hip�tese da devolu��o de compra interestadual.

@author	Erick G. Dias
@since	05/05/2016
/*/
//-------------------------------------------------------------------
User Function A95088MGNf(aNfDevComp,aPr88MG,aNFsProc,aAlias)

Local nCont	:= 0
Local nPerc	:= 0
Local nQtdPer	:= 0 
Local nIcmsStPer	:= 0
Local nIcmsPer	:= 0
Local cChave	:= ''
Local lUsaSFT	:= AliasInDic("SFT") .And. SFT->(FieldPos("FT_RGESPST")) > 0
Local l74Item	:= GetNewPar("MV_74ITEM",.F.)
Local nPos		:= 0

dbSelectArea("SD1")
dbSetOrder(1)

CriaTrb88(aAlias,l74Item)

For nCont	:= 1 to Len(aNfDevComp)
	nPerc	:= 0
	//Fazer Seek na SD1 e verificar se foi calculado ICMS ST na compra
	If SD1->(MsSeek(xFilial("SD1")+;
					  aNfDevComp[nCont][1]+;
					  aNfDevComp[nCont][2]+;
					  aNfDevComp[nCont][3]+;
	                aNfDevComp[nCont][4]+;
	                aNfDevComp[nCont][5]+;
	                aNfDevComp[nCont][6]))
		//Se nota original calculou ST
		
		If !SD1->D1_TIPO $ 'P/I/C' .AND. SD1->D1_BRICMS > 0
			
			nPerc		:= aNfDevComp[nCont][7] / SD1->D1_QUANT
			nQtdPer	:= aNfDevComp[nCont][7]
			nIcmsStPer	:= Round(SD1->D1_ICMSRET * nPerc,2)
			nIcmsPer	:= Round(SD1->D1_VALICM * nPerc,2)

			If !(aAlias[1])->(DbSeek(aNfDevComp[nCont][5]))
				RecLock(aAlias[1], .T. )
				(aAlias[1])->CODPRD   := aNfDevComp[nCont][5]
				(aAlias[1])->CODIGO	 := aNfDevComp[nCont][5]			
				
			Else
				RecLock(aAlias[1], .F. )
			EndIf
			
			(aAlias[1])->VALICMS  += nIcmsPer
			(aAlias[1])->ICMSRET  += nIcmsStPer
			(aAlias[1])->QUANT	 +=	 nQtdPer		
			MsUnLock()			
			
			nPos	:= aScan(aPr88MG,{|x| x[1]==aNfDevComp[nCont][5]})
			If nPos	== 0 
				aAdd(aPr88MG,{aNfDevComp[nCont][5],aNfDevComp[nCont][5],.T.,0})
			Else
				aPr88MG[nPos][3]	:= .T.
			EndIF
			
			If RetMonta88(SD1->D1_ICMSRET,SD1->D1_SERIE,;
							SD1->D1_DOC,SD1->D1_FORNECE,SD1->D1_LOJA,;
							SD1->D1_ITEM,SD1->D1_COD,lUsaSFT,aNfDevComp[nCont][8],SD1->D1_CF)
	
				//����������������������������������������������������������������������������������Ŀ
				//�Armazena o item da nota fiscal que foi processado para composicao do estoque de ST�
				//������������������������������������������������������������������������������������
				cChave := SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_COD+SD1->D1_ITEM
				If aScan(aNFsProc,{|x| x[1]+x[2]+x[3]+x[4]+x[5]+x[6]+x[7]==cChave}) == 0
					Aadd(aNFsProc,{SD1->D1_FILIAL,SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA,SD1->D1_COD,SD1->D1_ITEM,0})
				Endif
				
			Endif
			 
		EndIF		
	
	EndIF
	
Next nCont

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CriaTrb88
Fun��o que cria arquivo tempor�rio para registro 88 de Minas

@author	Erick G. Dias
@since	05/05/2016
/*/
//-------------------------------------------------------------------
Static Function CriaTrb88(aAlias,l74Item,aCampos)

Local cIndR74	:= ''
Local cChave	:= ''
Local cIndR74a	:= ''
Local cChavea	:= ''

Default aCampos	:= {}

If Len(aAlias)>0 
	If Select(aAlias[1]) <= 0
		aadd(aCampos,{"CODIGO"   ,"C", TamSx3("B1_COD")[1], 0})
		aadd(aCampos,{"CODPRD"   ,"C", TamSx3("B1_COD")[1], 0})
		aadd(aCampos,{"NCM"      ,"C", 14, 0})
		aadd(aCampos,{"CODNCM"   ,"C", 08, 0})
		aadd(aCampos,{"UM"       ,"C", 02, 0})
		aadd(aCampos,{"SITUACA"  ,"C", 01, 0})
		aadd(aCampos,{"QUANT"    ,"N", 19, 3})
		aadd(aCampos,{"CUSTO"    ,"N", 19, 4})
		aadd(aCampos,{"CNPJ"     ,"C", 14, 0})
		aadd(aCampos,{"INSCR"    ,"C", TamSX3("A2_INSCR")[1], 0})
		aadd(aCampos,{"UF"       ,"C", 02, 0})
		aadd(aCampos,{"NOME"     ,"C", 40, 0})
		aadd(aCampos,{"CODNOME"  ,"C", 06, 0})
		aadd(aCampos,{"BASEST"   ,"N", 14, 2})
		aadd(aCampos,{"VALST"    ,"N", 14, 2})
		aadd(aCampos,{"VALICMS"  ,"N", 14, 2})					//Valor do ICMS Operacao Propria
		aadd(aCampos,{"ICMSRET"  ,"N", 14, 2})					//Valor do ICMS ST
		aadd(aCampos,{"ALIQST"   ,"N", 05, 2})
		aadd(aCampos,{"CODINV"   ,"C", 01, 0})					//Campo utilizado pelo o SEF-PE
		aadd(aCampos,{"TIPO"     ,"C", TamSX3("B1_TIPO")[1],0}) //Campo com o tipo do produto
		aadd(aCampos,{"DESC_PRD" ,"C", 50, 0})					//Descricao produto
		aadd(aCampos,{"CLASSFIS" ,"C", 02, 0})					//Classificacao Fiscal
		aadd(aCampos,{"BASEICMS" ,"N", 14, 2})					//Base ICMS Proprio
		aAlias[2] := CriaTrab(aCampos,.T.)
		dbUseArea(.T.,__LocalDrive,aAlias[2],aAlias[1],.F.,.F.)
	
        If !l74Item
	   		cIndR74 := CriaTrab(NIL,.F.)
	   		cChave	:= "CODPRD"
	   		IndRegua(aAlias[1],cIndR74,cChave)
		Else
			cIndR74a := CriaTrab(NIL,.F.)
			cChavea	:= "CODPRD+SITUACA+CNPJ"
			IndRegua(aAlias[1],cIndR74a,cChavea)
		EndIF
	EndIf
Endif 

REturn

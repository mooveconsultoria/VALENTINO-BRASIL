#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RwMake.ch"
#include 'tbiconn.ch'



/*
* Funcao		:	RELPROVRH
* Autor			:	Tiago Maniero
* Data			: 	25/05/2021
* Descricao		:	Relat�rio RH Provis�o de f�rias e 13 salario
*/
user function RELPROVRH()

    if perg()   
        if alltrim(MV_PAR08) == "F�rias"
            FwMsgRun( Nil , { || u_provFerias() } , 'Processando' , "Gerando Relat�rio...   " )
        else
            FwMsgRun( Nil , { || u_provDecimo() } , 'Processando' , "Gerando Relat�rio...   " )
        endif
    endif


return

//Caixa de par�metros
static function perg()  
    local lRet      := .F.
    local aParamBox	:= {}
    local cPerg     := "Parametros de Planilha Provis�o"
    local aCombo    := {"Decimo Terceiro","F�rias"} 


    aAdd(aParamBox  ,{1,"Data"                ,Ctod(Space(8))                               ,"","",""      ,"",50,.F.})  		 	
    aAdd(aParamBox  ,{1,"Filial De"           ,Space(GetSx3Cache("RA_FILIAL","X3_TAMANHO")) ,"","","SM0EMP","", 6,.F.})  		 	
    aAdd(aParamBox  ,{1,"Filial Ate"          ,Space(GetSx3Cache("RA_FILIAL","X3_TAMANHO")) ,"","","SM0EMP","", 6,.T.})  		 	
    aAdd(aParamBox  ,{1,"Centro de Custo De"  ,Space(GetSx3Cache("CTT_CUSTO","X3_TAMANHO")) ,"","","CTT"   ,"", 6,.F.})  		 	
    aAdd(aParamBox  ,{1,"Centro de Custo Ate" ,Space(GetSx3Cache("CTT_CUSTO","X3_TAMANHO")) ,"","","CTT"   ,"", 6,.T.})
    aAdd(aParamBox  ,{1,"Matr�cula De"        ,Space(GetSx3Cache("RA_MAT","X3_TAMANHO"))    ,"","","SRA"   ,"", 6,.F.})  		 	
    aAdd(aParamBox  ,{1,"Matr�cula Ate"       ,Space(GetSx3Cache("RA_MAT","X3_TAMANHO"))    ,"","","SRA"   ,"", 6,.T.})
    aAdd(aParamBox  ,{2,"Tipo Provis�o"       ,1,aCombo,50,"",.T.})


return ParamBox(aParamBox,"Parametros de Planilha Provis�o",,,,,,,,cPerg,.F.,.F.)




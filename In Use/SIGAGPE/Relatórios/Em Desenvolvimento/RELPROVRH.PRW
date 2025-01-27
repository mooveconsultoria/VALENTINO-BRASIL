#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RwMake.ch"
#include 'tbiconn.ch'



/*
* Funcao		:	RELPROVRH
* Autor			:	Tiago Maniero
* Data			: 	25/05/2021
* Descricao		:	Relatório RH Provisão de férias e 13 salario
*/
user function RELPROVRH()

    if perg()   
        if alltrim(MV_PAR08) == "Férias"
            FwMsgRun( Nil , { || u_provFerias() } , 'Processando' , "Gerando Relatório...   " )
        else
            FwMsgRun( Nil , { || u_provDecimo() } , 'Processando' , "Gerando Relatório...   " )
        endif
    endif


return

//Caixa de parâmetros
static function perg()  
    local lRet      := .F.
    local aParamBox	:= {}
    local cPerg     := "Parametros de Planilha Provisão"
    local aCombo    := {"Decimo Terceiro","Férias"} 


    aAdd(aParamBox  ,{1,"Data"                ,Ctod(Space(8))                               ,"","",""      ,"",50,.F.})  		 	
    aAdd(aParamBox  ,{1,"Filial De"           ,Space(GetSx3Cache("RA_FILIAL","X3_TAMANHO")) ,"","","SM0EMP","", 6,.F.})  		 	
    aAdd(aParamBox  ,{1,"Filial Ate"          ,Space(GetSx3Cache("RA_FILIAL","X3_TAMANHO")) ,"","","SM0EMP","", 6,.T.})  		 	
    aAdd(aParamBox  ,{1,"Centro de Custo De"  ,Space(GetSx3Cache("CTT_CUSTO","X3_TAMANHO")) ,"","","CTT"   ,"", 6,.F.})  		 	
    aAdd(aParamBox  ,{1,"Centro de Custo Ate" ,Space(GetSx3Cache("CTT_CUSTO","X3_TAMANHO")) ,"","","CTT"   ,"", 6,.T.})
    aAdd(aParamBox  ,{1,"Matrícula De"        ,Space(GetSx3Cache("RA_MAT","X3_TAMANHO"))    ,"","","SRA"   ,"", 6,.F.})  		 	
    aAdd(aParamBox  ,{1,"Matrícula Ate"       ,Space(GetSx3Cache("RA_MAT","X3_TAMANHO"))    ,"","","SRA"   ,"", 6,.T.})
    aAdd(aParamBox  ,{2,"Tipo Provisão"       ,1,aCombo,50,"",.T.})


return ParamBox(aParamBox,"Parametros de Planilha Provisão",,,,,,,,cPerg,.F.,.F.)




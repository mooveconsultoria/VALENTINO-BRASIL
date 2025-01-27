#Include "Protheus.ch"
#Include "Topconn.ch"
#Include "TbiConn.ch"
#Include "TbiCode.ch"

/*-------------------------------------------------------------------------------------------------
@Autor: Mauricio Sena
@Data: 08/04/2022
@DescriÃ§Ã£o: Gatilho disparado na rotina de venda assistida a partir do campo do cabeÃ§alho Cliente.
            Executa os gatilhos do Grid apÃ³s a alteraÃ§Ã£o do cliente
--------------------------------------------------------------------------------------------------*/

User Function VAGAT031()

Local nX
Local nPosVDA := aScan(aHeader,{|x| AllTrim(x[2])=="LR_XTPVDA"})

If Valtype(aCols) == "A"
    For nX:=1 To Len(aCols)
        If !Empty(aCols[nX,2]) .and. !aCols[nX,Len(aHeader)+1]
            //If Valtype(aCols[nX,nPosVDA]) <> "U"
                //If !Empty(aCols[nX,nPosVDA])
                    runtrigger(2,nX,nil,nil,"LR_XTPVDA")
                //Endif
            //Endif
        Endif
    Next nX
Endif

Return

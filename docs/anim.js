numTex=0

function ShowTex()
{
  numTex++;
  if (numTex == 8)
    numTex = 0;
  document.theTex.src = 'Images/tex' + numTex + '.jpg';
   
  setTimeout("ShowTex()", 10000);
}

numDetail = 0;

function ShowDetail()
{
  numDetail++;
  if (numDetail == 8)
    numDetail = 0;
  document.theDetail.src = 'Images/detail' + numDetail + '.gif';
   
  setTimeout("ShowDetail()", 10000);
}

ShowTex();
setTimeout("ShowDetail()", 5000);

   
   

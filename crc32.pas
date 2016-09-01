{-------------------------------------------------------------
  This unit is freeware. I found it somewhere on CIS, I think.
  Peter Tiemann (www.preview.org)
 -------------------------------------------------------------}
Unit Crc32;

interface

function UpdateCRC32(InitCRC: LongWord; Buffer: Pointer; BufferLength: WORD): LongWord; overload;
function UpdateCRC32(crc: LongWord; value : integer): LongWord; overload;
function ComputeFileCRC32(const FileName: string): LongWord;
function ComputeStringCrc32(const s : string): LongWord;

implementation

type
   CRCTable = Array[0..255] of LongWord;

const
   BufferLength = 16384;
   CRC32Table: CRCTable = (
       $000000000, $077073096, $0ee0e612c, $0990951ba,
       $0076dc419, $0706af48f, $0e963a535, $09e6495a3,
       $00edb8832, $079dcb8a4, $0e0d5e91e, $097d2d988,
       $009b64c2b, $07eb17cbd, $0e7b82d07, $090bf1d91,

       $01db71064, $06ab020f2, $0f3b97148, $084be41de,
       $01adad47d, $06ddde4eb, $0f4d4b551, $083d385c7,
       $0136c9856, $0646ba8c0, $0fd62f97a, $08a65c9ec,
       $014015c4f, $063066cd9, $0fa0f3d63, $08d080df5,

       $03b6e20c8, $04c69105e, $0d56041e4, $0a2677172,
       $03c03e4d1, $04b04d447, $0d20d85fd, $0a50ab56b,
       $035b5a8fa, $042b2986c, $0dbbbc9d6, $0acbcf940,
       $032d86ce3, $045df5c75, $0dcd60dcf, $0abd13d59,

       $026d930ac, $051de003a, $0c8d75180, $0bfd06116,
       $021b4f4b5, $056b3c423, $0cfba9599, $0b8bda50f,
       $02802b89e, $05f058808, $0c60cd9b2, $0b10be924,
       $02f6f7c87, $058684c11, $0c1611dab, $0b6662d3d,

       $076dc4190, $001db7106, $098d220bc, $0efd5102a,
       $071b18589, $006b6b51f, $09fbfe4a5, $0e8b8d433,
       $07807c9a2, $00f00f934, $09609a88e, $0e10e9818,
       $07f6a0dbb, $0086d3d2d, $091646c97, $0e6635c01,

       $06b6b51f4, $01c6c6162, $0856530d8, $0f262004e,
       $06c0695ed, $01b01a57b, $08208f4c1, $0f50fc457,
       $065b0d9c6, $012b7e950, $08bbeb8ea, $0fcb9887c,
       $062dd1ddf, $015da2d49, $08cd37cf3, $0fbd44c65,

       $04db26158, $03ab551ce, $0a3bc0074, $0d4bb30e2,
       $04adfa541, $03dd895d7, $0a4d1c46d, $0d3d6f4fb,
       $04369e96a, $0346ed9fc, $0ad678846, $0da60b8d0,
       $044042d73, $033031de5, $0aa0a4c5f, $0dd0d7cc9,

       $05005713c, $0270241aa, $0be0b1010, $0c90c2086,
       $05768b525, $0206f85b3, $0b966d409, $0ce61e49f,
       $05edef90e, $029d9c998, $0b0d09822, $0c7d7a8b4,
       $059b33d17, $02eb40d81, $0b7bd5c3b, $0c0ba6cad,

       $0edb88320, $09abfb3b6, $003b6e20c, $074b1d29a,
       $0ead54739, $09dd277af, $004db2615, $073dc1683,
       $0e3630b12, $094643b84, $00d6d6a3e, $07a6a5aa8,
       $0e40ecf0b, $09309ff9d, $00a00ae27, $07d079eb1,

       $0f00f9344, $08708a3d2, $01e01f268, $06906c2fe,
       $0f762575d, $0806567cb, $0196c3671, $06e6b06e7,
       $0fed41b76, $089d32be0, $010da7a5a, $067dd4acc,
       $0f9b9df6f, $08ebeeff9, $017b7be43, $060b08ed5,

       $0d6d6a3e8, $0a1d1937e, $038d8c2c4, $04fdff252,
       $0d1bb67f1, $0a6bc5767, $03fb506dd, $048b2364b,
       $0d80d2bda, $0af0a1b4c, $036034af6, $041047a60,
       $0df60efc3, $0a867df55, $0316e8eef, $04669be79,

       $0cb61b38c, $0bc66831a, $0256fd2a0, $05268e236,
       $0cc0c7795, $0bb0b4703, $0220216b9, $05505262f,
       $0c5ba3bbe, $0b2bd0b28, $02bb45a92, $05cb36a04,
       $0c2d7ffa7, $0b5d0cf31, $02cd99e8b, $05bdeae1d,

       $09b64c2b0, $0ec63f226, $0756aa39c, $0026d930a,
       $09c0906a9, $0eb0e363f, $072076785, $005005713,
       $095bf4a82, $0e2b87a14, $07bb12bae, $00cb61b38,
       $092d28e9b, $0e5d5be0d, $07cdcefb7, $00bdbdf21,

       $086d3d2d4, $0f1d4e242, $068ddb3f8, $01fda836e,
       $081be16cd, $0f6b9265b, $06fb077e1, $018b74777,
       $088085ae6, $0ff0f6a70, $066063bca, $011010b5c,
       $08f659eff, $0f862ae69, $0616bffd3, $0166ccf45,

       $0a00ae278, $0d70dd2ee, $04e048354, $03903b3c2,
       $0a7672661, $0d06016f7, $04969474d, $03e6e77db,
       $0aed16a4a, $0d9d65adc, $040df0b66, $037d83bf0,
       $0a9bcae53, $0debb9ec5, $047b2cf7f, $030b5ffe9,

       $0bdbdf21c, $0cabac28a, $053b39330, $024b4a3a6,
       $0bad03605, $0cdd70693, $054de5729, $023d967bf,
       $0b3667a2e, $0c4614ab8, $05d681b02, $02a6f2b94,
       $0b40bbe37, $0c30c8ea1, $05a05df1b, $02d02ef8d);

var
   Buffer: Array[1..BufferLength] of Byte;

function UpdateCRC32(InitCRC: LongWord; Buffer: Pointer; BufferLength: WORD): LongWord;
var
   crc: LongWord;
   index: integer;
   i: integer;
begin
   crc := InitCRC;
   for i := 0 to BufferLength-1 do
   begin
    index := (crc  xor Integer(Pointer(LongWord(Buffer)+i)^)) and $000000FF;
    crc := ((crc shr 8) and $00FFFFFF) xor CRC32Table[index];
   end;
   Result := crc;
end;


function UpdateCRC32(crc: LongWord; value : integer): LongWord;
var
   index: integer;
begin
   index  := (crc xor value) and $000000FF;
   Result := ((crc shr 8) and $00FFFFFF) xor CRC32Table [index]
end;

function ComputeFileCRC32(const FileName : string): LongWord;
var
   InputFile: File;
   Crc32: LongWord;
   ResultLength: Integer;
   BufPtr: Pointer;
begin
   BufPtr := @Buffer;
   Assign(InputFile, FileName);
   Reset(InputFile, 1);
   Crc32 := $FFFFFFFF;    { 32 bit crc starts with all bits on }
   Repeat
     BlockRead(InputFile, Buffer, BufferLength, ResultLength);
     Crc32 := UpdateCrc32(Crc32, BufPtr, ResultLength);
   Until Eof(InputFile);
   Close(InputFile);
   Crc32 := Not(Crc32);   { Finish 32 bit crc by inverting all bits }
   Result := CRC32;
end;

function ComputeStringCrc32 (const s : string): LongWord;
begin
  if Length (s) = 0
    then Result := $FFFFFFFF
    else Result := UpdateCrc32 ($FFFFFFFF, Addr (s[1]), Length (s))
end;

end.

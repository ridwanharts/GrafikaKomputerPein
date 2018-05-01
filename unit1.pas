unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, ComCtrls, Spin, Buttons, types, FPCanvas, Windows; //Windows untuk menggunakan GetKeyState()

type

  { TForm1 }
  elemen = record
  x,y : real;
  end;


  TForm1 = class(TForm)
    bbSegitigaSama: TBitBtn;
    bbSegitigaSiku: TBitBtn;
    bbGaris: TBitBtn;
    editdlm: TEdit;
    Label11: TLabel;
    sbPPanjang: TSpeedButton;
    zoomout: TButton;
    rkanan: TButton;
    rkiri: TButton;
    zoomin: TButton;
    ColorButton1: TColorButton;
    ColorButton2: TColorButton;
    ComboBox1: TComboBox;
    Edit1: TEdit;
    Edit2: TEdit;
    FloatSpinEdit1: TFloatSpinEdit;
    Image1: TImage;
    Label1: TLabel;
    Label10: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    PageControl1: TPageControl;
    PageControl2: TPageControl;
    spinRotate: TSpinEdit;
    spinGaris: TSpinEdit;
    TabSheet1: TTabSheet;
    TabSheet3: TTabSheet;
    procedure bbGarisClick(Sender: TObject);
    procedure bbSegitigaSamaClick(Sender: TObject);
    procedure bbSegitigaSikuClick(Sender: TObject);
    procedure ColorButton2Click(Sender: TObject);
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure rkananClick(Sender: TObject);
    procedure rkiriClick(Sender: TObject);
    procedure sbPPanjangClick(Sender: TObject);
    procedure spinGarisChange(Sender: TObject);
    procedure zoominClick(APolygon: array of TPoint);
    procedure ColorButton1ColorChanged(Sender: TObject);
    procedure ColorButton2ColorChanged(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure BoundaryFill(x, y, fill, boundary: Integer);
    procedure FormActivate(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseLeave(Sender: TObject);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer
      );
    procedure zoomoutClick(APolygon: array of TPoint);
    procedure Reset;
    procedure Frame;
    function IsPointInPolygon(AX, AY:Integer; APolygon: array of TPoint): Boolean;
    procedure TemporaryGambar(temporaryPolygon: array of TPoint);
    procedure Gambar(APolygon: array of TPoint);
    procedure geserBangun(AX, AY, BX, BY: Integer);
    procedure MidPoint;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;
  APolygon, temporaryPolygon: array of TPoint;
  bmp: TBitmap;
  temporaryRect, ARect: TRect;
  obj:array[1..25] of elemen;
  npoints, s, i, k, n, titik, xmid, ymid:integer;
  d, r,skala,totalx, totaly:real;
  xmin, ymin, xmax, ymax, min, max, dx, dy, xawal, xakhir, xsekarang, ysekarang, yawal, yakhir:integer;
  namaBangun, dimensi : String;
  statusTahan,statusGambar, statusGeser : boolean;
implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormActivate(Sender: TObject);
begin
  Image1.canvas.Rectangle(0,0,Image1.Width,Image1.Height);
  statusTahan:=false;
  statusGambar:=false;
  statusGeser:=false;
  namaBangun:='';
  temporaryRect := TRect.Create(10,10,150,150);
  ARect := TRect.Create(10,10,150,150);
end;

procedure TForm1.Image1Click(Sender: TObject);
begin
  //editDlm.Text:=(APolygon[3].X).ToString;
  if(IsPointInPolygon(xawal,yawal,APolygon)) then
  begin
    editDlm.Text:='OK';
  end;
end;

procedure TForm1.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  xawal:=X;
  yawal:=Y;
  Image1.Canvas.CopyMode := cmWhiteness;
  temporaryRect := TRect.create(0, 0, Image1.Width, Image1.Height);
  statusTahan:=true;
  if(IsPointInPolygon(X,Y,APolygon)) and (statusGambar=false) then
  begin
    statusGeser := true;
  end;
end;

procedure TForm1.zoomoutClick(APolygon: array of TPoint);
begin
  skala:= FloatSpinEdit1.Value;
  i := 1;
  totalx:=0; totaly:=0;
  while i<=titik do
        begin
             totalx:=totalx+obj[i].x; totaly:=totaly+obj[i].y;
             i:=i+1;
        end;
  if titik>1 then
  begin
    xmid:=round(totalx/titik); ymid:=round(totaly/titik);
  end;
  i := 1;
  while (i<=titik) and (titik<>1) do
        begin
             obj[i].x:=xmid+((obj[i].x-xmid)/skala);
             obj[i].y:=ymid+((obj[i].y-ymid)/skala);
             i:=i+1;
        end;
  if s=4 then
    begin
      r:=d/2;
      xmid:=round(obj[1].x+r); ymid:=round(obj[1].y+r);
      if skala>1 then
        begin
          obj[1].x:=xmid-(r/skala);
          obj[1].y:=ymid-(r/skala);
          d:=d/skala;
        end
    end;
  Gambar(APolygon);
end;

procedure TForm1.BoundaryFill(x, y, fill, boundary: Integer);
  var
  current:Integer;
  begin
  current:=Image1.Canvas.Pixels[x,y];
  if((current<>boundary)and(current<>fill)) then
  begin
  Image1.Canvas.Pixels[x,y]:=fill;
  Image1.Refresh;
  //4titiksudut
  boundaryfill (x+1, y, fill, boundary);
  boundaryfill (x-1, y, fill, boundary);
  boundaryfill (x, y+1, fill, boundary);
  boundaryfill (x, y-1, fill, boundary);
  end;
end;

procedure TForm1.Image1MouseLeave(Sender: TObject);
begin
  edit1.text:='';
  edit2.text:='';
end;

procedure TForm1.Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  edit1.text:=inttostr(X);
  edit2.text:=inttostr(Y);
  editdlm.Text:=GetKeyState(VK_SHIFT).ToString;
  if(statusTahan) and (statusGambar) then
  begin
    xakhir:=X;
    yakhir:=Y;
    if(namaBangun='Garis') then
    begin
      APolygon[0] := Types.Point(xawal, yawal);
      APolygon[1] := Types.Point(xakhir, yakhir);
    end
    else if(namaBangun='Persegi Panjang') then
    begin
      if GetKeyState(VK_SHIFT)>=0 then
      begin
        APolygon[0] := Types.Point(xawal, yawal);
        APolygon[1] := Types.Point(xakhir, yawal);
        APolygon[2] := Types.Point(xakhir, yakhir);
        APolygon[3] := Types.Point(xawal, yakhir);
      end
      else
      begin
        dx:=abs(xakhir-xawal);
        dy:=abs(yakhir-yawal);
        if(dx<dy) then
        begin
          min:=dx;
        end
        else
        begin
          min:=dy;
        end;
        if (xakhir<xawal) and (yakhir<yawal) then
        begin
          editdlm.Text:='xakhir<xawal yakhir<yawal';
          APolygon[0] := Types.Point(xawal, yawal);
          APolygon[1] := Types.Point(xawal, yawal-min);
          APolygon[2] := Types.Point(xawal-min, yawal-min);
          APolygon[3] := Types.Point(xawal-min, yawal);
        end
        else if (xakhir>xawal) and (yakhir<yawal) then
        begin
          editdlm.Text:='xakhir>xawal yakhir<yawal';
          APolygon[0] := Types.Point(xawal, yawal);
          APolygon[1] := Types.Point(xawal, yawal-min);
          APolygon[2] := Types.Point(xawal+min, yawal-min);
          APolygon[3] := Types.Point(xawal+min, yawal);
        end
        else if (xakhir<xawal) and (yakhir>yawal) then
        begin
          editdlm.Text:='xakhir<xawal yakhir>yawal';
          APolygon[0] := Types.Point(xawal, yawal);
          APolygon[1] := Types.Point(xawal, yawal+min);
          APolygon[2] := Types.Point(xawal-min, yawal+min);
          APolygon[3] := Types.Point(xawal-min, yawal);
        end
        else if (xakhir>xawal) and (yakhir>yawal) then
        begin
          editdlm.Text:='xakhir>xawal yakhir>yawal';
          APolygon[0] := Types.Point(xawal, yawal);
          APolygon[1] := Types.Point(xawal, yawal+min);
          APolygon[2] := Types.Point(xawal+min, yawal+min);
          APolygon[3] := Types.Point(xawal+min, yawal);
        end;
      end;
    end
    else if(namaBangun='Segitiga Sama') then
    begin
      if GetKeyState(VK_SHIFT)>=0 then
            begin
              if(xawal<xakhir) then
              begin
                xmin:=xawal;
                xmax:=xakhir;
              end
              else
              begin
                xmin:=xakhir;
                xmax:=xawal;
              end;
              if(yawal<yakhir) then
              begin
                ymin:=yawal;
                ymax:=yakhir;
              end
              else
              begin
                ymin:=yakhir;
                ymax:=yawal;
              end;
              APolygon[0] := Types.Point(round((xawal+xakhir)/2), ymin);
              APolygon[1] := Types.Point(xmin, ymax);
              APolygon[2] := Types.Point(xmax, ymax);;
            end
            else
            begin
              dx:=abs(xakhir-xawal);
              dy:=abs(yakhir-yawal);
              if(dx<dy) then
              begin
                min:=dx;
              end
              else
              begin
                min:=dy;
              end;
              if (xakhir<xawal) and (yakhir<yawal) then
              begin
                editdlm.Text:='xakhir<xawal yakhir<yawal';
                APolygon[0] := Types.Point(xawal-min, yawal);
                APolygon[1] := Types.Point(xawal-round(min/2), yawal-min);
                APolygon[2] := Types.Point(xawal, yawal);
              end
              else if (xakhir>xawal) and (yakhir<yawal) then
              begin
                editdlm.Text:='xakhir>xawal yakhir<yawal';
                APolygon[0] := Types.Point(xawal+min, yawal);
                APolygon[1] := Types.Point(xawal+round(min/2), yawal-min);
                APolygon[2] := Types.Point(xawal, yawal);
              end
              else if (xakhir<xawal) and (yakhir>yawal) then
              begin
                editdlm.Text:='xakhir<xawal yakhir>yawal';
                APolygon[0] := Types.Point(xawal-min, yawal+min);
                APolygon[1] := Types.Point(xawal-round(min/2), yawal);
                APolygon[2] := Types.Point(xawal, yawal+min);
              end
              else if (xakhir>xawal) and (yakhir>yawal) then
              begin
                editdlm.Text:='xakhir>xawal yakhir>yawal';
                APolygon[0] := Types.Point(xawal+min, yawal+min);
                APolygon[1] := Types.Point(xawal+round(min/2), yawal);
                APolygon[2] := Types.Point(xawal, yawal+min);
              end;
            end;
    end
    else if(namaBangun='Segitiga Siku') then
    begin
      if GetKeyState(VK_SHIFT)>=0 then
            begin
              if xakhir < xawal then
              begin
                xmin:=xakhir;
                xmax:=xawal;
              end
              else
              begin
                xmin:=xawal;
                xmax:=xakhir;
              end;
              if yakhir < yawal then
              begin
                ymin:=yakhir;
                ymax:=yawal;
              end
              else
              begin
                ymin:=yawal;
                ymax:=yakhir;
              end;
              APolygon[0] := Types.Point(xmin, ymin);
              APolygon[1] := Types.Point(xmin, ymax);
              APolygon[2] := Types.Point(xmax, ymax);;
            end
            else
            begin
              dx:=abs(xakhir-xawal);
              dy:=abs(yakhir-yawal);
              if(dx<dy) then
              begin
                min:=dx;
              end
              else
              begin
                min:=dy;
              end;
              if (xakhir<xawal) and (yakhir<yawal) then
              begin
                editdlm.Text:='xakhir<xawal yakhir<yawal';
                APolygon[0] := Types.Point(xawal, yawal);
                APolygon[1] := Types.Point(xawal-min, yawal);
                APolygon[2] := Types.Point(xawal-min, yawal-min);
              end
              else if (xakhir>xawal) and (yakhir<yawal) then
              begin
                editdlm.Text:='xakhir>xawal yakhir<yawal';
                APolygon[0] := Types.Point(xawal, yawal);
                APolygon[1] := Types.Point(xawal, yawal-min);
                APolygon[2] := Types.Point(xawal+min, yawal);
              end
              else if (xakhir<xawal) and (yakhir>yawal) then
              begin
                editdlm.Text:='xakhir<xawal yakhir>yawal';
                APolygon[0] := Types.Point(xawal-min, yawal);
                APolygon[1] := Types.Point(xawal-min, yawal+min);
                APolygon[2] := Types.Point(xawal, yawal+min);
              end
              else if (xakhir>xawal) and (yakhir>yawal) then
              begin
                editdlm.Text:='xakhir>xawal yakhir>yawal';
                APolygon[0] := Types.Point(xawal, yawal);
                APolygon[1] := Types.Point(xawal, yawal+min);
                APolygon[2] := Types.Point(xawal+min, yawal+min);
              end;
            end;
    end;
    TemporaryGambar(APolygon);
  end;
  if(statusGeser) then
  begin
    editDlm.Text:=(not statusGambar).ToString;
    midPoint;
    xsekarang:=X;
    ysekarang:=Y;
    geserBangun(xmid, ymid, xsekarang, ysekarang);
  end;
end;

procedure TForm1.spinGarisChange(Sender: TObject);
begin
  Reset;
  Gambar(APolygon);
end;

procedure TForm1.ColorButton2Click(Sender: TObject);
begin

end;

procedure TForm1.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  xakhir:=X;
  yakhir:=Y;
  statusTahan:=false;
  if(statusGambar)then
  begin
    Gambar(APolygon);
  end;
  if(statusGeser) then
  begin
    APolygon:=temporaryPolygon;
    Gambar(APolygon);
    statusGeser:=false;
  end;
end;

procedure TForm1.rkananClick(Sender: TObject);
var
  rot:real;
begin
  rot:=spinRotate.Value;
  rot:=rot*pi/180;
  totalx:=0;
  totaly:=0;
  npoints:=length(APolygon);
  for i:=0 to npoints-1 do
        begin
          totalx:=totalx+APolygon[i].x;
          totaly:=totaly+APolygon[i].y;
        end;
  if npoints>1 then
  begin
    xmid:=round(totalx/npoints);
    ymid:=round(totaly/npoints);
  end;
  for i:=0 to npoints-1 do
    begin
         APolygon[i].x:=APolygon[i].x-xmid;
         APolygon[i].y:=APolygon[i].y-ymid;
         TemporaryPolygon[i].x:=round(APolygon[i].x*cos(rot)-APolygon[i].y*sin(rot));
         TemporaryPolygon[i].y:=round(APolygon[i].x*sin(rot)+APolygon[i].y*cos(rot));
         TemporaryPolygon[i].x:=TemporaryPolygon[i].x+xmid;
         TemporaryPolygon[i].y:=TemporaryPolygon[i].y+ymid;
         APolygon[i].x:=APolygon[i].x+xmid;
         APolygon[i].y:=APolygon[i].y+ymid;
    end;
  Gambar(TemporaryPolygon); //digambar Temporary karena koordinat hasil rotasi merupakan pembulatan
end;

procedure TForm1.rkiriClick(Sender: TObject);
var
  rot:real;
begin
  rot:=spinRotate.Value;
  rot:=-(rot*pi/180);
  totalx:=0;
  totaly:=0;
  npoints:=length(APolygon);
  for i:=0 to npoints-1 do
        begin
          totalx:=totalx+APolygon[i].x;
          totaly:=totaly+APolygon[i].y;
        end;
  if npoints>1 then
  begin
    xmid:=round(totalx/npoints);
    ymid:=round(totaly/npoints);
  end;
  for i:=0 to npoints-1 do
    begin
         APolygon[i].x:=APolygon[i].x-xmid;
         APolygon[i].y:=APolygon[i].y-ymid;
         TemporaryPolygon[i].x:=round(APolygon[i].x*cos(rot)-APolygon[i].y*sin(rot));
         TemporaryPolygon[i].y:=round(APolygon[i].x*sin(rot)+APolygon[i].y*cos(rot));
         APolygon[i]:=TemporaryPolygon[i];
         APolygon[i].x:=APolygon[i].x+xmid;
         APolygon[i].y:=APolygon[i].y+ymid;
    end;
  Gambar(APolygon);
end;

procedure TForm1.bbGarisClick(Sender: TObject);
begin
  statusGambar:=true;
  namaBangun:='Garis';
  SetLength(APolygon, 2);
  setLength(temporaryPolygon, 4);
end;

procedure TForm1.sbPPanjangClick(Sender: TObject);
begin
  statusGambar:=true;
  namaBangun:='Persegi Panjang';
  SetLength(APolygon, 4);
  setLength(temporaryPolygon, 4);
end;

procedure TForm1.bbSegitigaSamaClick(Sender: TObject);
begin
  statusGambar:=true;
  namaBangun:='Segitiga Sama';
  SetLength(APolygon, 3);
  setLength(temporaryPolygon, 3);
end;

procedure TForm1.bbSegitigaSikuClick(Sender: TObject);
begin
  statusGambar:=true;
  namaBangun:='Segitiga Siku';
  SetLength(APolygon, 3);
  setLength(temporaryPolygon, 3);
end;


procedure TForm1.zoominClick(APolygon: array of TPoint);
begin
  skala:= FloatSpinEdit1.Value;
  i := 1;
  totalx:=0; totaly:=0;
  while i<=titik do
        begin
             totalx:=totalx+obj[i].x; totaly:=totaly+obj[i].y;
             i:=i+1;
        end;
  if titik>1 then
  begin
    xmid:=round(totalx/titik); ymid:=round(totaly/titik);
  end;
  i := 1;
  while (i<=titik) and (titik<>1) do
        begin
             obj[i].x:=xmid+((obj[i].x-xmid)*skala);
             obj[i].y:=ymid+((obj[i].y-ymid)*skala);
             i:=i+1;
        end;
  if s=4 then
    begin
      r:=d/2;
      xmid:=round(obj[1].x+r); ymid:=round(obj[1].y+r);
      if skala>1 then
        begin
          obj[1].x:=xmid-(skala*r);
          obj[1].y:=ymid-(skala*r);
          d:=d*skala;
        end
    end;
  Gambar(APolygon);
end;

procedure TForm1.ColorButton1ColorChanged(Sender: TObject);
begin
  Gambar(APolygon);
end;

procedure TForm1.ColorButton2ColorChanged(Sender: TObject);
begin
  Gambar(APolygon);
end;

procedure TForm1.ComboBox1Change(Sender: TObject);
begin
  Gambar(APolygon);
end;

procedure TForm1.Reset;
begin
   Image1.Canvas.Pen.Style:=psSolid;
   Image1.Canvas.Pen.Color:=clblack;
   Image1.Canvas.Pen.Width:=1;
   Image1.Canvas.Brush.Color:=TColor($FFFFFF);
   image1.canvas.Rectangle(0,0,Image1.Width,Image1.Height);
end;

procedure TForm1.Frame;
begin
  Image1.Canvas.Pen.Style:=psSolid;
  Image1.Canvas.Pen.Color:=clblack;
  Image1.Canvas.Pen.Width:=1;
  Image1.Canvas.MoveTo(0,0);
  Image1.Canvas.LineTo(Image1.Width,0);
  Image1.Canvas.LineTo(Image1.Width,Image1.Height);
  Image1.Canvas.LineTo(0,Image1.Height);
  Image1.Canvas.LineTo(0,0);
end;

function TForm1.IsPointInPolygon(AX, AY:Integer; APolygon: array of TPoint): Boolean;
 var
   xnew, ynew : Cardinal;
   xold, yold : Cardinal;
   x1,y1 : Cardinal;
   x2,y2 : Cardinal;
   i, npoints : Integer;
   inside : Integer=0;
begin
 Result := False;
 npoints := Length(APolygon);
 if(npoints<3) then Exit;
 xold := APolygon[npoints-1].X;
 yold := APolygon[npoints-1].Y;
 for i:=0 to npoints-1 do
     begin
       xnew := APolygon[i].X;
       ynew := APolygon[i].Y;
       if (xnew>xold) then
         begin
           x1:=xold;
           x2:=xnew;
           y1:=yold;
           y2:=ynew;
         end
       else
         begin
           x1:=xnew;
           x2:=xold;
           y1:=ynew;
           y2:=yold;
         end;
       if (((xnew<AX) = (AX <= xold)) //edge "open" at left end
         and ((AY-y1)*(x2-x1) < (y2-y1)*(AX-x1))) then
           begin
             inside := not inside;
           end;
       xold:=xnew;
       yold:=ynew;
     end;
 Result:=inside<>0;
end;

procedure TForm1.TemporaryGambar(temporaryPolygon: array of TPoint);
begin
    Image1.Canvas.Pen.Style:=psDash;
    Image1.Canvas.Pen.Color:=clblack;
    Image1.Canvas.Pen.Width:=1;
    Image1.Canvas.Brush.Color:=TColor($FFFFFF);
    if(namaBangun<>'') then
    begin
      Image1.Canvas.CopyRect(temporaryRect,Image1.Canvas,ARect);
      Image1.Canvas.Polygon(temporaryPolygon);
      Frame;
    end;
end;

procedure TForm1.Gambar(APolygon: array of TPoint);
begin
    if ComboBox1.ItemIndex=0 then
       Image1.Canvas.Pen.Style := psDot
     else if ComboBox1.ItemIndex=1 then
       Image1.Canvas.Pen.Style := psDash
     else if ComboBox1.ItemIndex=2 then
       Image1.Canvas.Pen.Style := psSolid;
     Image1.Canvas.Pen.Width:=spinGaris.Value;
     Image1.Canvas.Pen.Color:=ColorButton1.ButtonColor;
     Image1.Canvas.Brush.Color:=ColorButton2.ButtonColor;
     Image1.Canvas.Polygon(APolygon);
     statusGambar:=false;
     Frame;
end;

procedure TForm1.MidPoint;
var
  totalx, totaly : Integer;
begin
   totalx:=0;
   totaly:=0;
   npoints := Length(APolygon);
   if(npoints<3) then Exit;
   for i:=0 to npoints-1 do
   begin
        totalx:=totalx+APolygon[i].x;
        totaly:=totaly+APolygon[i].y;
   end;
     xmid:=round(totalx/npoints);
     ymid:=round(totaly/npoints);
end;

procedure TForm1.geserBangun(AX, AY, BX, BY: Integer);
begin
  dx:=BX-AX;
  dy:=BY-AY;
  for i:=0 to npoints-1 do
  begin
    temporaryPolygon[i]:=Types.Point(APolygon[i].X+dx, APolygon[i].Y+dy);
  end;
    TemporaryGambar(temporaryPolygon);
end;

end.


{ Diese Datei wurde automatisch von Lazarus erzeugt. Sie darf nicht bearbeitet werden!
Dieser Quelltext dient nur dem Übersetzen und Installieren des Packages.
 }

unit Pexpandpanels; 

interface

uses
  ExpandPanels, LazarusPackageIntf; 

implementation

procedure Register; 
begin
  RegisterUnit('ExpandPanels', @ExpandPanels.Register); 
end; 

initialization
  RegisterPackage('Pexpandpanels', @Register); 
end.

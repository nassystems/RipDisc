@powershell.exe -nop "$me = '%~f0';. ([scriptblock]::create((gc -li $me|select -skip 1|out-string)))" %*&goto:eof
$here = Split-Path $me -Parent
<#
.SYNOPSIS
This script rip discs in the drive.
.NOTES
Disc ripper version 1.00

MIT License

Copyright (c) 2021 Isao Sato

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#>
$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
Set-StrictMode -Version 2
$OutputEncoding = [console]::OutputEncoding

New-Variable -Name buffsize -Value (4*1024*1024) -Option Constant
$buff = New-Object Byte[] $buffsize

if($null -eq (Get-Variable |? {$_.Name -eq 'LocalWin32HelperTypes'})) {& {
	$DefiningTypes = @{}
	$global:LocalWin32HelperTypes = New-Object System.Collections.Generic.Dictionary[string`,type]
	
	$appdomain = [AppDomain]::CurrentDomain
	$asmbuilder = $appdomain.DefineDynamicAssembly((New-Object Reflection.AssemblyName 'LocalWin32Helper'), [Reflection.Emit.AssemblyBuilderAccess]::Run)
	$modbuilder = $asmbuilder.DefineDynamicModule('LocalWin32Helper.dll')
	
	$modbuilder |% {
		$_.DefineType(
			'NASsystems.LocalWin32Helper',
			[System.Reflection.TypeAttributes] 'AutoLayout, AnsiClass, Class, Public, BeforeFieldInit',
			[System.Object]
			) |% {
			$DefiningTypes['NASsystems.LocalWin32Helper'] = @{}
			$DefiningTypes['NASsystems.LocalWin32Helper'].Builder = $_
			$_.DefineNestedType(
				'GENERIC_RIGHT',
				[System.Reflection.TypeAttributes] 'AutoLayout, AnsiClass, Class, NestedPublic, Sealed',
				[System.Enum]
				) |% {
				$DefiningTypes['NASsystems.LocalWin32Helper+GENERIC_RIGHT'] = @{}
				$DefiningTypes['NASsystems.LocalWin32Helper+GENERIC_RIGHT'].Builder = $_
			} | Out-Null
		} | Out-Null
	}
	
	function Create-CustomAttributeBuilder([Reflection.ConstructorInfo] $constructor, [object[]] $arguments, [System.Collections.Hashtable] $attributes)
	{
		$AttributeFields = New-Object Collections.Generic.List[Reflection.FieldInfo]
		$AttributeValues = New-Object Collections.Generic.List[Object]
		
		$attributes.GetEnumerator() |% {
			$AttributeFields.Add($constructor.ReflectedType.GetField($_.Key)) | Out-Null
			$AttributeValues.Add($_.Value) | Out-Null
		}
		
		New-Object Reflection.Emit.CustomAttributeBuilder ($constructor, $arguments, $AttributeFields.ToArray(), $AttributeValues.ToArray())
	}
	
	$DefiningTypes['NASsystems.LocalWin32Helper'].Builder |% {
		$_ | Out-Null
		$_ | Out-Null
		$_.DefineConstructor(
			[System.Reflection.MethodAttributes] 'Private, Static',
			[System.Reflection.CallingConventions]::Standard,
			@()
			) |% {
			$DefiningTypes['NASsystems.LocalWin32Helper'].StaticConstructorILGen = $_.GetILGenerator()
		} | Out-Null
		$_.SetCustomAttribute(
			(Create-CustomAttributeBuilder `
				([System.Runtime.InteropServices.StructLayoutAttribute].GetConstructor(@([System.Runtime.InteropServices.LayoutKind]))) `
				@(([System.Runtime.InteropServices.LayoutKind] 'Auto')) `
				@{
					CharSet = ([System.Runtime.InteropServices.CharSet] 'Ansi')
					Pack = 8
					Size = 0
				}
				)
			) | Out-Null
		$_.DefineMethod(
			'CreateFile',
			[System.Reflection.MethodAttributes] 'PrivateScope, Public, Static, HideBySig, PinvokeImpl',
			[System.IntPtr],
			@([System.String], [System.Int32], [System.IO.FileShare], [System.IntPtr], [System.IO.FileMode], [System.Int32], [System.IntPtr])
			) |% {
			$_.SetCustomAttribute(
				(Create-CustomAttributeBuilder `
					([System.Runtime.InteropServices.DllImportAttribute].GetConstructor(@([System.String]))) `
					@(([System.String] 'kernel32.dll')) `
					@{
						EntryPoint = 'CreateFile' # [System.String]
						CharSet = 3 # [System.Runtime.InteropServices.CharSet]
						SetLastError = $true # [System.Boolean]
						PreserveSig = $true # [System.Boolean]
						CallingConvention = 1 # [System.Runtime.InteropServices.CallingConvention]
					}
					)
				) | Out-Null
			$_.SetCustomAttribute(
				(Create-CustomAttributeBuilder `
					([System.Runtime.InteropServices.PreserveSigAttribute].GetConstructor(@())) `
					@() `
					@{
					}
					)
				) | Out-Null
			$_.SetImplementationFlags([System.Reflection.MethodImplAttributes] 'PreserveSig') | Out-Null
			$_.DefineParameter(
				1,
				[System.Reflection.ParameterAttributes] 'None',
				'lpFileName'
				) | Out-Null
			$_.DefineParameter(
				2,
				[System.Reflection.ParameterAttributes] 'None',
				'dwDesiredAccess'
				) | Out-Null
			$_.DefineParameter(
				3,
				[System.Reflection.ParameterAttributes] 'None',
				'dwShareMode'
				) | Out-Null
			$_.DefineParameter(
				4,
				[System.Reflection.ParameterAttributes] 'None',
				'lpSecurityAttributes'
				) | Out-Null
			$_.DefineParameter(
				5,
				[System.Reflection.ParameterAttributes] 'None',
				'dwCreationDisposition'
				) | Out-Null
			$_.DefineParameter(
				6,
				[System.Reflection.ParameterAttributes] 'None',
				'dwFlagsAndAttributes'
				) | Out-Null
			$_.DefineParameter(
				7,
				[System.Reflection.ParameterAttributes] 'None',
				'hTemplateFile'
				) | Out-Null
		} | Out-Null
		$_.DefineMethod(
			'CloseHandle',
			[System.Reflection.MethodAttributes] 'PrivateScope, Public, Static, HideBySig, PinvokeImpl',
			[System.Boolean],
			@([System.IntPtr])
			) |% {
			$_.SetCustomAttribute(
				(Create-CustomAttributeBuilder `
					([System.Runtime.InteropServices.DllImportAttribute].GetConstructor(@([System.String]))) `
					@(([System.String] 'kernel32.dll')) `
					@{
						EntryPoint = 'CloseHandle' # [System.String]
						CharSet = 1 # [System.Runtime.InteropServices.CharSet]
						SetLastError = $true # [System.Boolean]
						PreserveSig = $true # [System.Boolean]
						CallingConvention = 1 # [System.Runtime.InteropServices.CallingConvention]
					}
					)
				) | Out-Null
			$_.SetCustomAttribute(
				(Create-CustomAttributeBuilder `
					([System.Runtime.InteropServices.PreserveSigAttribute].GetConstructor(@())) `
					@() `
					@{
					}
					)
				) | Out-Null
			$_.SetImplementationFlags([System.Reflection.MethodImplAttributes] 'PreserveSig') | Out-Null
			$_.DefineParameter(
				1,
				[System.Reflection.ParameterAttributes] 'None',
				'hObject'
				) | Out-Null
		} | Out-Null
		$_.DefineField(
			'INVALID_HANDLE_VALUE',
			[System.IntPtr],
			[System.Reflection.FieldAttributes] 'Public, Static, InitOnly'
			) |% {
			$DefiningTypes['NASsystems.LocalWin32Helper'].StaticConstructorILGen.Emit([System.Reflection.Emit.OpCodes]::Ldc_I8, ([int64] -1))
			$DefiningTypes['NASsystems.LocalWin32Helper'].StaticConstructorILGen.Emit([System.Reflection.Emit.OpCodes]::Newobj, [System.IntPtr].GetConstructor(@([System.Int64])))
			$DefiningTypes['NASsystems.LocalWin32Helper'].StaticConstructorILGen.Emit([System.Reflection.Emit.OpCodes]::Stsfld, $_)
		} | Out-Null
		$_.DefineField(
			'MAX_PATH',
			[System.Int32],
			[System.Reflection.FieldAttributes] 'Public, Static, Literal, HasDefault'
			) |% {
			$_.SetConstant(260)
		} | Out-Null
		$DefiningTypes['NASsystems.LocalWin32Helper'].StaticConstructorILGen.Emit([System.Reflection.Emit.OpCodes]::Ret)
	} | Out-Null
	$DefiningTypes['NASsystems.LocalWin32Helper+GENERIC_RIGHT'].Builder |% {
		$_.SetCustomAttribute(
			(Create-CustomAttributeBuilder `
				([System.Runtime.InteropServices.StructLayoutAttribute].GetConstructor(@([System.Runtime.InteropServices.LayoutKind]))) `
				@(([System.Runtime.InteropServices.LayoutKind] 'Auto')) `
				@{
					CharSet = ([System.Runtime.InteropServices.CharSet] 'Ansi')
					Pack = 8
					Size = 0
				}
				)
			) | Out-Null
		$_.SetCustomAttribute(
			(Create-CustomAttributeBuilder `
				([System.FlagsAttribute].GetConstructor(@())) `
				@() `
				@{
				}
				)
			) | Out-Null
		$_.DefineField(
			'value__',
			[System.Int32],
			[System.Reflection.FieldAttributes] 'Public, SpecialName, RTSpecialName'
			) | Out-Null
		$_.DefineField(
			'READ',
			$DefiningTypes['NASsystems.LocalWin32Helper+GENERIC_RIGHT'].Builder,
			[System.Reflection.FieldAttributes] 'Public, Static, Literal, HasDefault'
			) |% {
			$_.SetConstant(-2147483648)
		} | Out-Null
	} | Out-Null
	
	@(
		'NASsystems.LocalWin32Helper',
		'NASsystems.LocalWin32Helper+GENERIC_RIGHT'
	) |% {$LocalWin32HelperTypes[$_] = $DefiningTypes[$_].Builder.CreateType()}

	[psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')::Add(
		'LocalWin32Helper',
		$LocalWin32HelperTypes['NASsystems.LocalWin32Helper']
		)
	[psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')::Add(
		'LocalWin32Helper+GENERIC_RIGHT',
		$LocalWin32HelperTypes['NASsystems.LocalWin32Helper+GENERIC_RIGHT']
		)
}}

$tgtdrvlst = Get-WmiObject Win32_CDROMDrive |? {$_.MediaLoaded}
if($null -ne $tgtdrvlst) {
    foreach($tgtdrv in $tgtdrvlst) {
        $SourceDrive = $tgtdrv.Drive
        $SourcePath = '\\?\{0}' -f $SourceDrive
        $IsoFilePath = $tgtdrv.VolumeName
        if([string]::IsNullOrEmpty($IsoFilePath)) {
            $IsoFilePath = '{0:yyyyMMdd-HHmmssff}' -f [datetime]::Now
        }
        $IsoFilePath = [System.IO.Path]::ChangeExtension($IsoFilePath, '.iso')
        $IsoFilePath = Join-Path $here $IsoFilePath
        
        Write-Host ('source drive     : {0}' -f $SourceDrive)
        Write-Host ('destination path : {0}' -f $IsoFilePath)
        
        $hdev = [LocalWin32Helper]::CreateFile($SourcePath, [LocalWin32Helper+GENERIC_RIGHT]::READ, [System.IO.FileShare]::Read, [System.IntPtr]::Zero, [System.IO.FileMode]::Open, [System.IO.FileAttributes]::Normal, [System.IntPtr]::Zero)
        $err = [System.Runtime.InteropServices.Marshal]::GetLastWin32Error()
        if($hdev -eq [LocalWin32Helper]::INVALID_HANDLE_VALUE) {
            Write-Error (New-Object System.IO.IOException ('can not open drive {0}' -f $SourceDrive), (New-Object System.ComponentModel.Win32Exception $err)) -ErrorAction Stop
        }
        try {
            $rd = $null
            $wr = $null
            try {
                $rd = New-Object System.IO.FileStream($hdev, [System.IO.FileAccess]::Read, $buffsize)
                $wr = New-Object System.IO.FileStream($IsoFilePath, [System.IO.FileMode]::CreateNew, [System.IO.FileAccess]::Write, [System.IO.FileShare]::None, $buffsize);
                do {
                    $rdlength = $rd.Read($buff, 0, $buffsize)
                    $wr.Write($buff, 0, $rdlength)
                    Write-Host '.' -NoNewline
                } until($rdlength -le 0)
                Write-Host
                Write-Host ' done.'
            }
            finally {
                if($rd){$rd.Dispose()}
                if($wr){$wr.Dispose()}
            }
        }
        finally {
            [LocalWin32Helper]::CloseHandle($hdev) | Out-Null
        }
    }
} else {
    Write-Warning 'Any target discs were not found.'
}
Write-Host '[Enter] for exit.'
Read-Host
# -*- mode: python ; coding: utf-8 -*-


a = Analysis(
    ['pytk_gui_builder.py'],
    pathex=[],
    binaries=[],
    datas=[
        ('page.tcl', '.'),
        ('version', '.'),
        ('images', 'images'),
        ('assets', 'assets'),
        ('docs/html', 'docs/html'),
        ('lib', 'lib'),
        ('themes', 'themes'),
        ('Img/Img1.4.13-Darwin64', 'Img/Img1.4.13-Darwin64'),
    ],
    hiddenimports=['tkinter'],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    noarchive=False,
    optimize=0,
)
pyz = PYZ(a.pure)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.datas,
    [],
    name='pytk_gui_builder',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    upx_exclude=[],
    runtime_tmpdir=None,
    console=False,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
)
app = BUNDLE(
    exe,
    name='pytk_gui_builder.app',
    icon='assets/app.icns',
    bundle_identifier=None,
)
$path = "c:\Users\haruk\Downloads\f\app.js"
$content = Get-Content -Path $path -Raw -Encoding UTF8

# 正規表現パターン: return ( ... <header> ... </header> までをキャプチャ
# 注意: <header>の中身は可変なので、[\s\S]+?で最短一致させる
$targetPattern = '(?s)return \(\s+<div className="flex h-screen overflow-hidden bg-gray-100">\s+<div className="flex-1 flex flex-col relative h-full overflow-hidden">\s+<header className="bg-white shadow-sm px-4 py-2 flex items-center justify-between z-10 border-b">.+?</header>'

# 新しいコンテンツ
$replacement = 'return (
                <div className="flex h-screen overflow-hidden bg-gray-50">
                    {/* サイドバー */}
                    <aside className="w-56 bg-white border-r border-gray-200 flex flex-col shadow-sm z-20">
                        {/* ロゴ・タイトルエリア */}
                        <div className="p-4 border-b border-gray-100">
                            <div className="flex items-center gap-2 mb-1">
                                {worldData?.mainPageId && (
                                    <button onClick={() => {
                                        const mainArt = articles.find(a => a.id === worldData.mainPageId);
                                        if (mainArt) { setSelectedArticle(mainArt); setViewMode(''single_article''); }
                                    }} className="p-1.5 text-indigo-600 hover:bg-indigo-50 rounded transition-colors" title="メインページ">
                                        <Icon name="landmark" size={20} />
                                    </button>
                                )}
                                <span className="text-sm font-bold text-gray-800 truncate flex-1">{worldData?.name || ''WorldWeaver''}</span>
                            </div>
                            <div className="text-[10px] text-gray-400 pl-1 cursor-pointer hover:text-indigo-600 flex items-center gap-1" onClick={copyMyId} title="IDコピー">
                                <Icon name="user" size={10} /> {user?.displayName || ''ゲスト''} (ID)
                            </div>
                        </div>
                        
                        {/* ナビゲーションメニュー */}
                        <nav className="flex-1 overflow-y-auto py-2 px-2 space-y-1">
                            {VIEW_TABS.map(tab => (
                                <button 
                                    key={tab.key} 
                                    onClick={() => setViewMode(tab.key)} 
                                    className={`w-full px-3 py-2 text-left text-sm rounded flex items-center gap-3 transition-colors ${
                                        viewMode === tab.key 
                                            ? ''bg-indigo-50 text-indigo-700 font-bold shadow-sm'' 
                                            : ''text-gray-600 hover:bg-gray-100''
                                    }`}
                                >
                                    <Icon name={tab.icon} size={18} />
                                    <span>{tab.label}</span>
                                </button>
                            ))}
                        </nav>
                        
                        {/* サイドバーフッター */}
                        <div className="p-3 border-t border-gray-100 space-y-2">
                            {isMember && (
                                <button onClick={() => {
                                    setPreviousViewMode(viewMode);
                                    setFormData(createEmptyArticle());
                                    setStats([]);
                                    setTagInput('''');
                                    setViewMode(''edit'');
                                }} className="w-full px-3 py-2 bg-indigo-600 text-white rounded text-sm font-bold shadow-sm flex items-center justify-center gap-2 hover:bg-indigo-700 transition-colors">
                                    <Icon name="plus" size={16} /> {canIApprove ? ''新規作成'' : ''作成申請''}
                                </button>
                            )}
                            <button onClick={() => setViewMode(''world_select'')} className="w-full px-3 py-1.5 text-xs text-gray-500 hover:bg-gray-100 rounded flex items-center justify-center gap-1.5 transition-colors border border-transparent hover:border-gray-200">
                                <Icon name="globe" size={14} /> 世界選択に戻る
                            </button>
                        </div>
                    </aside>

                    {/* メインコンテンツエリア */}
                    <div className="flex-1 flex flex-col relative h-full overflow-hidden">
                        {/* 簡易ヘッダー */}
                        <header className="bg-white px-4 py-2 flex items-center justify-between z-10 border-b border-gray-200 h-12">
                            <div className="text-xs text-gray-400 flex items-center gap-1">
                                <Icon name="layout" size={12} /> <span className="hidden sm:inline">Current View:</span> <span className="font-semibold text-gray-600">{VIEW_TABS.find(t => t.key === viewMode)?.label || viewMode}</span>
                            </div>
                            <div className="flex items-center gap-2 md:gap-4">
                                {(viewMode === ''timeline_large'' || viewMode === ''list'' || viewMode === ''map'') && (
                                    <button onClick={() => setTimelineFilters(prev => ({ ...prev, onlyApproved: !prev.onlyApproved }))} className={`flex items-center gap-1 text-xs px-2 py-1 rounded transition-colors ${timelineFilters.onlyApproved ? ''bg-emerald-600 text-white font-bold'' : ''bg-gray-100 text-gray-500 hover:bg-gray-200''}`} title="承認済み記事のみ表示">
                                        <Icon name="check-circle" size={14} />
                                        <span className="hidden sm:inline">承認済のみ</span>
                                    </button>
                                )}
                                <div className="hidden lg:flex items-center text-[10px] text-gray-400 bg-gray-50 px-2 py-1 rounded">
                                    <Icon name="filter" size={10} className="mr-1" /> 
                                    <span className="truncate max-w-[150px]">{timelineSummary}</span>
                                    {timelineFilters.onlyApproved && <span className="text-emerald-600 font-bold ml-1">(ON)</span>}
                                </div>
                                {(myRole === ''owner'' || myRole === ''admin'') && (
                                    <button onClick={() => setShowAdminPanel(true)} title="管理パネル" className="text-gray-500 hover:text-indigo-600 p-1.5 rounded hover:bg-gray-100 transition-colors">
                                        <Icon name="settings" size={18} />
                                    </button>
                                )}
                            </div>
                        </header>'

$newContent = [Regex]::Replace($content, $targetPattern, $replacement)

if ($newContent -eq $content) {
    Write-Host "No match found!"
    exit 1
}

$newContent | Set-Content -Path $path -Encoding UTF8
Write-Host "Successfully replaced content"

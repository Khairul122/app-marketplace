<!doctype html>
<html lang="id">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>{{ $title ?? 'Admin' }} - Ootday</title>
    <link rel="icon" href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 24 24%22><text y=%2220%22 font-size=%2220%22>🛍️</text></svg>">
    @vite(['resources/css/app.css', 'resources/js/app.js'])
    @livewireStyles
</head>
<body class="bg-slate-100 text-slate-800 min-h-screen flex">
    <!-- Global request indicator -->
    <div wire:loading.delay.default class="fixed top-0 left-0 right-0 h-1 z-[9998] bg-gradient-to-r from-rose-500 via-pink-500 to-violet-500 bg-[length:200%_100%] animate-[shimmer_1.2s_linear_infinite]"></div>
    @php
        $navItems = [
            [
                'route' => 'admin.dashboard',
                'label' => 'Dashboard',
                'icon' => '<svg class="w-5 h-5" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M4 6a2 2 0 012-2h2a2 2 0 012 2v4a2 2 0 01-2 2H6a2 2 0 01-2-2V6zM14 6a2 2 0 012-2h2a2 2 0 012 2v4a2 2 0 01-2 2h-2a2 2 0 01-2-2V6zM4 16a2 2 0 012-2h2a2 2 0 012 2v4a2 2 0 01-2 2H6a2 2 0 01-2-2v-4zM14 16a2 2 0 012-2h2a2 2 0 012 2v4a2 2 0 01-2 2h-2a2 2 0 01-2-2v-4z"></path></svg>'
            ],
            [
                'route' => 'admin.users.index',
                'label' => 'Users',
                'icon' => '<svg class="w-5 h-5" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"></path></svg>'
            ],
            [
                'route' => 'admin.stores.index',
                'label' => 'Stores',
                'icon' => '<svg class="w-5 h-5" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"></path></svg>'
            ],
            [
                'route' => 'admin.categories.index',
                'label' => 'Categories',
                'icon' => '<svg class="w-5 h-5" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M4 6h16M4 12h16M4 18h7"></path></svg>'
            ],
            [
                'route' => 'admin.products.index',
                'label' => 'Products',
                'icon' => '<svg class="w-5 h-5" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"></path></svg>'
            ],
            [
                'route' => 'admin.orders.index',
                'label' => 'Orders',
                'icon' => '<svg class="w-5 h-5" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-3 7h3m-3 4h3m-6-4h.01M9 16h.01"></path></svg>'
            ],
            [
                'route' => 'admin.payment-methods.index',
                'label' => 'Payment Methods',
                'icon' => '<svg class="w-5 h-5" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z"></path></svg>'
            ],
            [
                'route' => 'admin.shipping-methods.index',
                'label' => 'Shipping Methods',
                'icon' => '<svg class="w-5 h-5" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M9 17a2 2 0 11-4 0 2 2 0 014 0zM19 17a2 2 0 11-4 0 2 2 0 014 0zM13 16V6a1 1 0 00-1-1H4a1 1 0 00-1 1v10M13 16h6a1 1 0 001-1v-4a1 1 0 00-1-1h-2m-3-7h3m-3 4h3"></path></svg>'
            ],
        ];
    @endphp

    <aside class="w-64 bg-white border-r border-slate-100 flex-shrink-0 min-h-screen flex flex-col shadow-sm">
        <div class="px-6 py-6 text-xl font-black tracking-tight border-b border-slate-100 flex items-center gap-2">
            <span class="bg-gradient-to-r from-rose-500 via-pink-500 to-violet-600 bg-clip-text text-transparent">Ootday Admin</span>
        </div>
        <nav class="py-6 px-4 space-y-1.5 flex-1 overflow-y-auto">
            @foreach ($navItems as $item)
                @php
                    $isActive = request()->routeIs($item['route']);
                @endphp
                <a href="{{ route($item['route']) }}"
                    class="flex items-center gap-3 px-4 py-3 text-sm font-semibold rounded-xl transition-all duration-200 {{ $isActive ? 'text-white bg-gradient-to-r from-rose-500 to-pink-500 shadow-sm shadow-rose-500/20' : 'text-slate-500 hover:bg-slate-50 hover:text-slate-800' }}">
                    {!! $item['icon'] !!}
                    <span>{{ $item['label'] }}</span>
                </a>
            @endforeach
        </nav>
        <form method="POST" action="{{ route('admin.logout') }}" class="px-6 py-5 border-t border-slate-100 mt-auto">
            @csrf
            <button type="submit" class="flex items-center gap-2 text-sm font-semibold text-rose-500 hover:text-rose-600 hover:translate-x-1 transition-all duration-200 w-full">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"></path></svg>
                <span>Keluar</span>
            </button>
        </form>
    </aside>

    <main class="flex-1 min-h-screen bg-slate-50 flex flex-col">
        <header class="bg-white border-b border-slate-100 px-8 py-5 flex items-center justify-between shadow-sm">
            <div>
                <h1 class="text-xl font-bold text-slate-800 tracking-tight">{{ $title ?? 'Dashboard' }}</h1>
                <p class="text-xs text-slate-400 mt-0.5 font-medium">Platform / {{ $title ?? 'Dashboard' }}</p>
            </div>
            <div class="flex items-center gap-3">
                <span class="text-xs font-semibold px-2.5 py-1 bg-rose-50 text-rose-600 rounded-full border border-rose-100/50">Admin Mode</span>
                <div class="w-8 h-8 rounded-full bg-rose-100 border border-rose-200 flex items-center justify-center font-bold text-rose-700 text-sm">
                    A
                </div>
            </div>
        </header>
        <div class="p-8 max-w-7xl w-full mx-auto flex-1">
            {{ $slot }}
        </div>
    </main>

    <!-- Beautiful Dialog Box Modal -->
    <div id="alertDialog" style="display: none; opacity: 0; transition: opacity 0.25s ease; background-color: rgba(15, 23, 42, 0.45); backdrop-filter: blur(4px);" class="fixed inset-0 items-center justify-center z-[9999]">
        <div id="alertDialogContent" style="transform: scale(0.95); transition: transform 0.25s ease;" class="bg-white rounded-2xl shadow-xl border border-slate-100 p-6 w-full max-w-sm">
            <div class="flex flex-col items-center text-center space-y-4">
                <!-- Icon -->
                <div id="alertDialogIcon" class="p-3 rounded-full flex items-center justify-center">
                    <!-- SVG icon injected here -->
                </div>
                <!-- Title & Message -->
                <div class="space-y-1">
                    <h3 class="text-lg font-bold text-slate-800" id="alertDialogTitle">Notifikasi</h3>
                    <p class="text-sm text-slate-500 leading-relaxed" id="alertDialogMessage"></p>
                </div>
                <!-- Action Button -->
                <button onclick="closeAlertDialog()" class="w-full mt-2 py-2.5 px-4 text-sm font-semibold text-white bg-slate-800 hover:bg-slate-900 rounded-xl shadow-sm hover:shadow transition-all duration-200">
                    OK
                </button>
            </div>
        </div>
    </div>

    <script>
        function showAlertDialog(title, message, type = 'success') {
            const dialog = document.getElementById('alertDialog');
            const content = document.getElementById('alertDialogContent');
            const titleEl = document.getElementById('alertDialogTitle');
            const messageEl = document.getElementById('alertDialogMessage');
            const iconEl = document.getElementById('alertDialogIcon');
            
            if (!dialog || !content || !titleEl || !messageEl || !iconEl) return;
            
            titleEl.textContent = title;
            messageEl.textContent = message;
            
            // Clear icon classes
            iconEl.className = 'p-3 rounded-full flex items-center justify-center';
            
            if (type === 'success') {
                iconEl.classList.add('bg-emerald-50', 'text-emerald-500');
                iconEl.innerHTML = `
                    <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                    </svg>
                `;
            } else {
                iconEl.classList.add('bg-rose-50', 'text-rose-500');
                iconEl.innerHTML = `
                    <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                    </svg>
                `;
            }
            
            // Display: flex then trigger layout reflow before opacity/transform transitions
            dialog.style.display = 'flex';
            dialog.style.pointerEvents = 'auto';
            
            // Force layout reflow
            dialog.offsetHeight;
            
            dialog.style.opacity = '1';
            content.style.transform = 'scale(1)';
        }
        
        function closeAlertDialog() {
            const dialog = document.getElementById('alertDialog');
            const content = document.getElementById('alertDialogContent');
            
            if (!dialog || !content) return;
            
            dialog.style.opacity = '0';
            content.style.transform = 'scale(0.95)';
            dialog.style.pointerEvents = 'none';
            
            setTimeout(() => {
                dialog.style.display = 'none';
            }, 250);
        }
        
        function checkAndShowAlerts() {
            const alerts = document.querySelectorAll('.alert-flash-data');
            alerts.forEach(el => {
                const type = el.getAttribute('data-type');
                const message = el.getAttribute('data-message');
                const id = el.getAttribute('data-id') || Math.random().toString();
                
                // Skip empty alerts
                if (!message || message.trim() === '') {
                    return;
                }
                
                if (!window.shownAlerts) {
                    window.shownAlerts = new Set();
                }
                if (window.shownAlerts.has(id)) {
                    return;
                }
                window.shownAlerts.add(id);
                
                showAlertDialog(type === 'success' ? 'Berhasil' : 'Gagal', message, type);
            });
        }

        window.addEventListener('DOMContentLoaded', () => {
            // General Session Success/Error check with non-empty checks & safe json_encode
            @if (session('success') && is_string(session('success')) && trim(session('success')) !== '')
                showAlertDialog('Berhasil', {!! json_encode(session('success')) !!}, 'success');
            @endif
            @if (session('error') && is_string(session('error')) && trim(session('error')) !== '')
                showAlertDialog('Gagal', {!! json_encode(session('error')) !!}, 'error');
            @endif
            @if ($errors->any() && is_string($errors->first()) && trim($errors->first()) !== '')
                showAlertDialog('Gagal', {!! json_encode($errors->first()) !!}, 'error');
            @endif

            // Check hidden alert-flash-data containers
            checkAndShowAlerts();
            
            // Set up MutationObserver to automatically capture Livewire component updates
            const observer = new MutationObserver(() => {
                checkAndShowAlerts();
            });
            observer.observe(document.body, { childList: true, subtree: true });
        });
    </script>

    @livewireScripts
</body>
</html>

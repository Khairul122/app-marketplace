<?php

namespace App\Livewire\Admin\Users;

use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Livewire\Attributes\Layout;
use Livewire\Component;
use Livewire\WithPagination;

#[Layout('admin.layout')]
class Index extends Component
{
    use WithPagination;

    public string $search = '';
    public string $roleFilter = '';
    public ?int $viewingId = null;
    public bool $showForm = false;
    public ?int $confirmingDeleteId = null;

    public string $name = '';
    public string $email = '';
    public string $phone = '';
    public string $role = 'pelanggan';
    public string $password = '';

    public function updatingSearch()
    {
        $this->resetPage();
    }

    public function updatingRoleFilter()
    {
        $this->resetPage();
    }

    public function view(int $id)
    {
        $this->viewingId = $id;
    }

    public function closeView()
    {
        $this->viewingId = null;
    }

    public function create()
    {
        $this->reset(['name', 'email', 'phone', 'role', 'password']);
        $this->role = 'pelanggan';
        $this->showForm = true;
    }

    public function cancelForm()
    {
        $this->showForm = false;
    }

    public function save()
    {
        $this->validate([
            'name' => ['required', 'string', 'max:100'],
            'email' => ['required', 'email', 'max:100', 'unique:users,email'],
            'phone' => ['nullable', 'string', 'max:20'],
            'role' => ['required', 'in:pelanggan,owner,admin'],
            'password' => ['required', 'string', 'min:8'],
        ]);

        User::create([
            'name' => $this->name,
            'email' => $this->email,
            'phone' => $this->phone ?: null,
            'role' => $this->role,
            'password' => Hash::make($this->password),
        ]);

        $this->showForm = false;
        session()->flash('success', 'User berhasil ditambahkan.');
    }

    public function confirmDelete(int $id)
    {
        $this->confirmingDeleteId = $id;
    }

    public function cancelDelete()
    {
        $this->confirmingDeleteId = null;
    }

    public function delete(int $id)
    {
        $user = User::findOrFail($id);
        $user->delete();
        $this->confirmingDeleteId = null;
        session()->flash('success', 'User berhasil dihapus.');
    }

    public function render()
    {
        $users = User::query()
            ->with('store')
            ->when($this->search, fn ($q) => $q->where(function ($q) {
                $q->where('name', 'like', "%{$this->search}%")
                    ->orWhere('email', 'like', "%{$this->search}%");
            }))
            ->when($this->roleFilter, fn ($q) => $q->where('role', $this->roleFilter))
            ->latest()
            ->paginate(15);

        return view('livewire.admin.users.index', [
            'users' => $users,
            'viewingUser' => $this->viewingId
                ? User::with(['store', 'addresses', 'orders'])->find($this->viewingId)
                : null,
        ]);
    }
}

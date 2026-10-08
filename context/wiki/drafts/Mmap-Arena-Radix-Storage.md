# ChainDB: mmap Arena + Radix Storage

## Решение

Следующий физический слой ChainDB строим не поверх Scheme `hashtable`, records или heap `bytevector`.

Основа:

```text
Chez Scheme
    ↓ FFI
mmap
    ↓
raw memory region
    ↓
Arena
    ├── fixed-size cells
    └── byte/payload pool
```

Chez Scheme управляет машиной, но основное состояние базы находится **вне Scheme heap**.

## Адресация

Внутри Arena не храним абсолютные C pointers.

Все связи представлены относительными offset/index:

```text
address = arena_base + offset
```

Это позволяет:

- не создавать Scheme-объекты для каждого элемента базы;
- не отдавать структуру базы под управление GC;
- сохранить relocatable memory image;
- позже естественно перейти к file-backed `mmap`.

## Первый индекс — Radix Tree

KV-storage переводим с hash table на radix tree.

Причина: ключ ChainDB уже является последовательностью байтов, а будущему Graph layer необходима естественная prefix-навигация.

Концептуально:

```text
raw key bytes
     ↓
Radix Tree
     ↓
ArenaRef / offset
     ↓
payload
```

Radix также размещается непосредственно в mmap Arena.

## Минимальная физическая модель

Пока не фиксируем окончательный размер и layout ячейки.

Нам принципиально нужны только:

```text
NodeRef = integer offset
NULL    = reserved offset

RadixCell
    tag
    prefix_ref
    value_ref
    first_child
    next_sibling
```

Переменные данные находятся в byte pool:

```text
[len][raw bytes...]
```

Точный размер полей выбираем после первого работающего эксперимента.

## Первый эксперимент

Graph пока не реализуем.

Сначала доказываем физический механизм:

```text
mmap
 ↓
Arena allocator
 ↓
Radix cells
 ↓
PUT raw bytes
 ↓
prefix traversal / split
 ↓
GET raw bytes
```

После того как работают exact lookup и prefix traversal, начинаем укладывать поверх этого Graph model.

## Принцип

Не строим временную версию radix на Scheme records с последующим переписыванием.

Первый radix сразу является машиной над mmap Arena:

> **Scheme задаёт алгоритм и управление; mmap Arena хранит физическое состояние ChainDB.**

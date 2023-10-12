const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;
const expect = std.testing.expect;
var alloc = std.heap.GeneralPurposeAllocator(.{}){};
const person = @import("function.zig");

const Node = struct {
    data: u8,
    next: ?*Node,
};

const Linkedlist = struct {
    head: ?*Node,
    tail: ?*Node,

    pub fn new() Linkedlist {
        return Linkedlist{
            .head = null,
            .tail = null,
        };
    }

    pub fn push_back(self: *Linkedlist, data: u8) !void {
        var node = try alloc.allocator().create(Node);
        node.data = data;
        node.next = null;

        if (self.tail == null and self.head == null) {
            self.tail = node;
            self.head = node;
        } else {
            self.tail.?.next = node;
            self.tail = node;
        }
    }

    pub fn push_front(self: *Linkedlist, data: u8) !void {
        var node = try alloc.allocator().create(Node);
        node.data = data;

        if (self.head == null and self.tail == null) {
            node.next = null;
            self.tail = node;
        } else {
            node.next = self.head;
        }

        self.head = node;
    }

    pub fn pop_front(self: *Linkedlist) u8 {
        const data = self.head.?.data;
        const head_ptr = self.head.?;
        self.head = self.head.?.next.?;
        defer alloc.allocator().destroy(head_ptr);
        return data;
    }

    pub fn pop_back(self: *Linkedlist) void {
        const tail_ptr: ?*Node = self.tail;
        defer alloc.allocator().destroy(tail_ptr.?);
        var node: ?*Node = self.head;
        while (node.?.next != self.tail) {
            node = node.?.next;
        }
        self.tail = node;
    }

    pub fn size(self: *Linkedlist) u8 {
        var node: ?*Node = self.head;
        var total_items: u8 = 0;

        while (node != null) {
            node = node.?.next;
            total_items += 1;
        }

        return total_items;
    }

    pub fn is_empty(self: *Linkedlist) bool {
        if (self.head == null or self.tail == null) {
            return true;
        }
        return false;
    }

    pub fn value_at(self: *Linkedlist, index: u8) u8 {
        var contable: u8 = 0;
        var node: ?*Node = self.head;

        while (node != null) {
            if (index == contable) {
                return node.?.data;
            }
            node = node.?.next;
            contable += 1;
        }

        return 0;
    }

    pub fn front(self: *Linkedlist) u8 {
        return self.head.?.data;
    }

    pub fn back(self: *Linkedlist) u8 {
        return self.tail.?.data;
    }

    pub fn insert(self: *Linkedlist, index: u8, value: u8) !void {
        var node: *Node = try alloc.allocator().create(Node);
        node.data = value;

        var contable: u8 = 1;
        var node_iterable = self.head;
        while (node_iterable != null) {
            node_iterable = node_iterable.?.next;
            if (contable == index) {
                break;
            }
            contable += 1;
        }
        node.next = node_iterable.?.next;
        node_iterable.?.next = node;
    }
};

pub fn main() !void {
    const result = person.person.greeting();
    print("{d}", .{result});
}

test "add_node" {
    var linkedlist = Linkedlist.new();
    try linkedlist.push_back(10);
    try linkedlist.push_back(20);
    try linkedlist.push_back(30);
    print("{}", .{linkedlist.tail.?.data});
    try expect(linkedlist.tail.?.data == 30);
}

test "dealloc_front" {
    var linkedlist = Linkedlist.new();
    try linkedlist.push_front(10);
    try linkedlist.push_front(20);
    var value = linkedlist.pop_front();
    print("{d}", .{value});
}

test "dealloc_back" {
    var linkedlist = Linkedlist.new();
    try linkedlist.push_back(20);
    try linkedlist.push_back(30);
    linkedlist.pop_back();
    try expect(linkedlist.tail.?.data == 20);
}

test "total" {
    var linkedlist = Linkedlist.new();
    try linkedlist.push_back(10);
    try linkedlist.push_back(20);
    try expect(linkedlist.size() == 2);
}

test "is_empty_test" {
    var linkedlist = Linkedlist.new();
    try expect(linkedlist.is_empty());
}

test "search_by_index" {
    var linkedlist = Linkedlist.new();
    try linkedlist.push_back(10);
    try linkedlist.push_back(20);
    var value = linkedlist.value_at(1);
    try expect(value == 20);
}

test "get_back" {
    var linkedlist = Linkedlist.new();
    try linkedlist.push_back(10);
    var last_value = linkedlist.back();
    try expect(last_value == 10);
}

test "insert_some_value" {
    var linkedlist = Linkedlist.new();
    try linkedlist.push_back(10);
    try linkedlist.push_back(20);
    try linkedlist.push_back(30);
    try linkedlist.insert(1, 40);
    try expect(linkedlist.head.?.next.?.data == 40);
}

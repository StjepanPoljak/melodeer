#include "mdgarbage.h"

#include <stdlib.h>
#include <errno.h>

#include "mdlog.h"

struct md_garbage_t {
	md_buf_chunk_t** chunks;
	int first;
	int last;
	int size;
} garbage;

int md_garbage_init(int size) {

	garbage.first = 0;
	garbage.last = 0;
	garbage.chunks = NULL;
	garbage.size = size;

	garbage.chunks = malloc(sizeof(*garbage.chunks) * size);
	if (!garbage.chunks) {
		md_error("Could not allocate memory.");
		return -ENOMEM;
	}

	return 0;
}

bool md_garbage_is_full(void) {

	/* [ ][L][F][ ] */
	if (garbage.last == garbage.first - 1)
		return true;

	/* [F][ ][ ][L] */
	if (garbage.first == 0 && garbage.last == garbage.size - 1)
		return true;

	return false;
}

static void md_garbage_free(md_buf_chunk_t* chunk) {
	md_buf_chunk_t* temp;

	temp = chunk;
	free(temp);

	return;
}

bool md_garbage_del_first(void) {

	if (garbage.first == garbage.last)
		return false;

	md_garbage_free(garbage.chunks[garbage.first++]);

	if (garbage.first >= garbage.size)
		garbage.first = 0;

	if (garbage.first == garbage.last)
		garbage.first = garbage.last = 0;

	return true;
}

void md_add_to_garbage(md_buf_chunk_t* chunk) {

	if (md_garbage_is_full())
		(void)md_garbage_del_first();

	garbage.chunks[garbage.last++] = chunk;

	if (garbage.last >= garbage.size)
		garbage.last = 0;

	return;
}

void md_garbage_deinit(void) {

	while (md_garbage_del_first()) { }

	free(garbage.chunks);

	return;
}
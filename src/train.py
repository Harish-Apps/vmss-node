import argparse, os, math
from datasets import load_dataset
from transformers import AutoTokenizer, AutoModelForCausalLM, Trainer, TrainingArguments

def parse_args():
    p = argparse.ArgumentParser()
    p.add_argument("--model_name", default="distilgpt2")
    p.add_argument("--epochs", type=int, default=1)
    p.add_argument("--batch_size", type=int, default=8)
    p.add_argument("--lr", type=float, default=5e-5)
    return p.parse_args()

def main():
    args = parse_args()
    model_name = args.model_name

    # tiny dataset to keep runtime/cost minimal
    ds = load_dataset("wikitext", "wikitext-2-raw-v1")
    tokenizer = AutoTokenizer.from_pretrained(model_name, use_fast=True)
    if tokenizer.pad_token_id is None:
        tokenizer.pad_token = tokenizer.eos_token

    def tok(batch):
        return tokenizer(batch["text"], truncation=True, max_length=128)

    tokenized = ds.map(tok, batched=True, remove_columns=["text"])

    model = AutoModelForCausalLM.from_pretrained(model_name)

    out_dir = os.environ.get("AZUREML_OUTPUTS_DIR", "./outputs")
    os.makedirs(out_dir, exist_ok=True)

    training_args = TrainingArguments(
        output_dir=out_dir,
        per_device_train_batch_size=args.batch_size,
        per_device_eval_batch_size=args.batch_size,
        learning_rate=args.lr,
        num_train_epochs=args.epochs,
        evaluation_strategy="steps",
        eval_steps=100,
        save_steps=200,
        logging_steps=20,
        fp16=True if os.environ.get("NVIDIA_VISIBLE_DEVICES") else False,
        report_to=["none"],
    )

    trainer = Trainer(
        model=model,
        args=training_args,
        train_dataset=tokenized["train"].select(range(2000)),
        eval_dataset=tokenized["validation"].select(range(1000)),
        tokenizer=tokenizer,
    )

    train_out = trainer.train()
    metrics = trainer.evaluate()
    ppl = math.exp(metrics["eval_loss"]) if metrics.get("eval_loss") else float("nan")
    print(f"Eval loss: {metrics.get('eval_loss')}, Perplexity: {ppl}")

    # save final model
    trainer.save_model(out_dir)

if __name__ == "__main__":
    main()
